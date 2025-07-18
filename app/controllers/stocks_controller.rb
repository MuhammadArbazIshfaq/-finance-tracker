class StocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock, only: [:show, :destroy]

  def index
    @stocks = current_user.stocks.order(:symbol)
    @total_value = @stocks.sum(&:price) || 0
  end

  def show
    # Get live data from Polygon API
    polygon_service = PolygonService.new
    @live_data = polygon_service.get_stock_quote(@stock.symbol)
    
    # Update the stock price if we got valid data
    if @live_data[:price] && !@live_data[:error]
      @stock.update(price: @live_data[:price])
    end
  end

  def new
    @stock = Stock.new
  end

def create
   raw_symbol =
    if params[:stock].is_a?(Hash) || params[:stock].is_a?(ActionController::Parameters)
      params[:stock][:symbol]
    else
      params[:symbol]
    end

  symbol = raw_symbol.to_s.upcase

  if symbol.blank?
    redirect_to new_stock_path, alert: "Please enter a stock symbol."
    return
  end

  symbol = symbol.upcase

  # Check if user already has this stock
  existing_stock = Stock.find_by(symbol: symbol)
  if existing_stock && current_user.stocks.include?(existing_stock)
    redirect_to stocks_path, alert: "You already have this stock in your portfolio!"
    return
  end

  # Get stock data from Polygon API
  polygon_service = PolygonService.new
  stock_data = polygon_service.get_stock_quote(symbol)

  if stock_data[:error]
    redirect_to new_stock_path, alert: "Error: #{stock_data[:error]}"
  else
    # Find or create the stock
    @stock = Stock.find_or_create_by(symbol: stock_data[:symbol]) do |stock|
      stock.name = stock_data[:name]
      stock.price = stock_data[:price]
    end

    # Update price if stock already exists
    @stock.update(price: stock_data[:price]) if @stock.persisted?

    # Add stock to user's portfolio
    current_user.stocks << @stock unless current_user.stocks.include?(@stock)

    redirect_to stocks_path, notice: 'Stock was successfully added to your portfolio!'
  end
end


  def destroy
    # Remove the stock from user's portfolio (removes the association)
    current_user.stocks.delete(@stock)
    redirect_to stocks_path, notice: "Stock was successfully removed from your portfolio."
  end

  def search
    if params[:search].present?
      polygon_service = PolygonService.new
      @search_results = polygon_service.search_stocks(params[:search])

      # If search_results is a hash with error, convert to empty array
      @search_results = [] if @search_results.is_a?(Hash) && @search_results[:error]
    else
      flash[:alert] = "Please enter a search term."
      @search_results = []
    end

    respond_to do |format|
      format.html
      format.json { render json: @search_results }
    end
  end

  private

  def set_stock
    @stock = current_user.stocks.find(params[:id])
  end

  def stock_params
    if params[:stock].is_a?(ActionController::Parameters)
      params.require(:stock).permit(:symbol)
    else
      # Handle case where params might be processed differently
      { symbol: params.dig(:stock, :symbol) || params[:symbol] }
    end
  end
end
