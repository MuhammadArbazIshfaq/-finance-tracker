class PolygonService
  include HTTParty
  base_uri "https://api.polygon.io"

  def initialize
    @api_key = Rails.application.credentials.polygon_api_key || ENV["POLYGON_API_KEY"] || "1FTcSbXUMijyEfxUdakHpX_WTCp4mv3y"
  end

  def get_stock_quote(symbol)
    return { error: 'API key not configured' } unless @api_key

    options = {
      query: {
        apikey: @api_key
      }
    }

    begin
      response = self.class.get("/v2/aggs/ticker/#{symbol}/prev", options)
      
      if response.success?
        data = response.parsed_response
        if data['results'] && data['results'].any?
          result = data["results"].first
          {
            symbol: symbol.upcase,
            name: get_company_name(symbol),
            price: result['c'], # closing price
            open: result['o'],
            high: result['h'],
            low: result['l'],
            volume: result['v']
          }
        else
          { error: 'No data found for this symbol' }
        end
      else
        { error: "API Error: #{response.code} - #{response.message}" }
      end
    rescue => e
      { error: "Connection error: #{e.message}" }
    end
  end

  def search_stocks(query)
    return { error: 'API key not configured' } unless @api_key

    options = {
      query: {
        search: query,
        apikey: @api_key
      }
    }

    begin
      response = self.class.get("/v3/reference/tickers", options)
      
      if response.success?
        data = response.parsed_response
        if data['results']
          data['results'].map do |stock|
            {
              symbol: stock['ticker'],
              name: stock['name'],
              market: stock['market'],
              type: stock['type']
            }
          end
        else
          []
        end
      else
        { error: "API Error: #{response.code} - #{response.message}" }
      end
    rescue => e
      { error: "Connection error: #{e.message}" }
    end
  end

  private

  def get_company_name(symbol)
    return symbol unless @api_key

    options = {
      query: {
        apikey: @api_key
      }
    }

    begin
      response = self.class.get("/v3/reference/tickers/#{symbol}", options)
      
      if response.success?
        data = response.parsed_response
puts "Fetching company name for #{symbol}: #{data}"
        data.dig('results', 'name') || symbol.upcase
      else
        symbol.upcase
      end
    rescue
      symbol.upcase
    end
  end
end
