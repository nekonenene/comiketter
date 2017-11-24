class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :login

  def login
    user_id = session[:user_id]
    @current_user = user_id.present? ? User.find(user_id) : nil
  end
end
