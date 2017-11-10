class AuthController < ApplicationController
  def new
    redirect_to "/auth/#{params[:provider]}"
  end

  def create
    case provider = params[:provider]
    when "twitter"
      puts "YES, Twitter!"

      auth = request.env["omniauth.auth"]
      p auth
    else
      raise "Provider \"#{provider}\" is not supported"
    end

    redirect_to root_url
  end

  def destroy
    redirect_to root_url
  end
end
