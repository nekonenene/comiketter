class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :login

  def login
    user_id = session[:user_id]
    @current_user = User.find_by(id: user_id) # nil or User
  end
end
