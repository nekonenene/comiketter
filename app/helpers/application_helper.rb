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

  def twitter_user_url(handle)
    "https://twitter.com/" + handle
  end
end
