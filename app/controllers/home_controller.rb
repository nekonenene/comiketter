class HomeController < ApplicationController
  def index
    if @current_user.present?
      @user_data ||= TwitterApi::UserData.new(@current_user)
      @followers = @user_data.followers
      @friends = @user_data.friends
    end
  end
end
