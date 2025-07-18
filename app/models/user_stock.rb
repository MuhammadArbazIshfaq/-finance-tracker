class UserStock < ApplicationRecord
  belongs_to :user
  belongs_to :stock
  
  # Prevent duplicate associations
  validates :user_id, uniqueness: { scope: :stock_id }
end
