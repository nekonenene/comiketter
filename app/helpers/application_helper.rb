module ApplicationHelper
  def app_name
    ENV["APP_NAME"]
  end

  def user_signed_in?
    @current_user.present?
  end

  def current_user
    @current_user
  end
end
