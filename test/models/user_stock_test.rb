require "test_helper"

class UserStockTest < ActiveSupport::TestCase
  test "user can have many stocks through user_stocks" do
    user = users(:one)
    stock1 = stocks(:one)
    stock2 = stocks(:two)
    
    # Add stocks to user
    user.stocks << stock1
    user.stocks << stock2
    
    assert_equal 2, user.stocks.count
    assert_includes user.stocks, stock1
    assert_includes user.stocks, stock2
  end
  
  test "stock can have many users through user_stocks" do
    stock = stocks(:one)
    user1 = users(:one)
    user2 = users(:two)
    
    # Add users to stock
    stock.users << user1
    stock.users << user2
    
    assert_equal 2, stock.users.count
    assert_includes stock.users, user1
    assert_includes stock.users, user2
  end
  
  test "prevents duplicate user-stock associations" do
    user_stock = UserStock.new(user: users(:one), stock: stocks(:one))
    assert user_stock.save
    
    # Try to create duplicate
    duplicate = UserStock.new(user: users(:one), stock: stocks(:one))
    assert_not duplicate.save
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end
end
