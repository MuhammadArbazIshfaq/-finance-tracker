class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :user_stocks, dependent: :destroy
  has_many :stocks, through: :user_stocks
  
  # Helper method to check if user already has a stock
  def has_stock?(symbol)
    stocks.exists?(symbol: symbol.upcase)
  end
  
  # Helper method to add stock to user's portfolio
  def add_stock(stock)
    user_stocks.create(stock: stock) unless has_stock?(stock.symbol)
  end
  
  # Helper method to remove stock from user's portfolio
  def remove_stock(stock)
    user_stocks.find_by(stock: stock)&.destroy
  end
end
