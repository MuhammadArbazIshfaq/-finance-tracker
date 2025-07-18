class Stock < ApplicationRecord
  has_many :user_stocks, dependent: :destroy
  has_many :users, through: :user_stocks
  
  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  
  before_save :upcase_symbol
  
  private
  
  def upcase_symbol
    self.symbol = symbol.upcase if symbol
  end
end
