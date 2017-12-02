class HomeController < ApplicationController
  def index
    if @current_user.present?
      user_data_api = TwitterApi::UserData.new(@current_user)
      user_data_api.update_followers
      user_data_api.update_friends
    end
  end
end
