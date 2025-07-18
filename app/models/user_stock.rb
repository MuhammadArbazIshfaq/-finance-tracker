class UserStock < ApplicationRecord
  belongs_to :user
  belongs_to :stock
  
  # Ensure a user can't add the same stock twice
  validates :user_id, uniqueness: { scope: :stock_id, message: "You already have this stock in your portfolio" }
end
