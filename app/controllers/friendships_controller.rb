class FriendshipsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @friends = current_user.friends
    @search_results = []
    
    # Handle search functionality
    if params[:search].present?
      search_term = params[:search].strip
      @search_results = User.search_by_email(search_term)
                           .where.not(id: current_user.id)
                           .limit(10)
    end
  end
  
  def create
    @friend = User.find(params[:friend_id])
    
    if @friend == current_user
      redirect_to my_friends_path, alert: "You cannot add yourself as a friend!"
      return
    end
    
    if current_user.friends.include?(@friend)
      redirect_to my_friends_path, alert: "#{@friend.email} is already your friend!"
      return
    end
    
    current_user.friendships.create(friend: @friend)
    redirect_to my_friends_path, notice: "#{@friend.email} has been added as your friend!"
  end
  
  def destroy
    @friend = User.find(params[:id])
    friendship = current_user.friendships.find_by(friend: @friend)
    
    if friendship
      friendship.destroy
      redirect_to my_friends_path, notice: "#{@friend.email} has been removed from your friends!"
    else
      redirect_to my_friends_path, alert: "Friend not found!"
    end
  end
  
  private
  
  def friendship_params
    params.permit(:friend_id, :search)
  end
end