class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_stocks, dependent: :destroy
  has_many :stocks, through: :user_stocks
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, source: :friend
  
  # Search scope for finding users
  scope :search_by_email, ->(search_term) {
    where("lower(email) LIKE ?", "%#{search_term.downcase}%")
  }
  
  def display_name
    email.split('@').first.titleize
  end
  
  # Check if this user is friends with another user
  def friends_with?(other_user)
    friends.include?(other_user)
  end
end
