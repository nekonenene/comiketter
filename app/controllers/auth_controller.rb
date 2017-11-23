class AuthController < ApplicationController
  def new
    redirect_to "/auth/#{params[:provider]}"
  end

  def create
    case provider = params[:provider]
    when "twitter"
      response_data = request.env["omniauth.auth"].except("extra")
      user = User.create_by_response(response_data)
      p user
    else
      raise "Provider \"#{provider}\" is not supported"
    end

    redirect_to root_url
  end

  def destroy
    redirect_to root_url
  end
end
