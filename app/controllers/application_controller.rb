class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :login, :set_notification

  def login
    user_id = session[:user_id]
    @current_user = User.find_by(id: user_id) # nil or User
  end

  def set_notification
    request.env["exception_notifier.exception_data"] = {
      server: request.env["SERVER_NAME"],
      user_agent: request.env["HTTP_USER_AGENT"],
    }
  end
end
