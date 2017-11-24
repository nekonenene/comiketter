class AuthController < ApplicationController
  def signin
    redirect_to "/auth/#{params[:provider]}"
  end

  def create
    case provider = params[:provider]
    when "twitter"
      response_data = request.env["omniauth.auth"].except("extra")
      user = User.find_or_create_by_response(response_data)
      session[:user_id] = user.id
    else
      flash[:alert] = I18n.t("auth.not_supported_provider", provider: provider.capitalize)
    end

    redirect_to root_url
  end

  def signout
    session[:user_id] = nil
    redirect_to root_url
  end

  def failure
    provider = params[:strategy]
    flash[:alert] = I18n.t("auth.signin_failed", provider: provider&.capitalize)

    redirect_to root_url
  end
end
