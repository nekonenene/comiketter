class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    @user = User.from_omniauth(request.env["omniauth.auth"].except("extra"))
    callback_from :twitter
  end

  def failure
    exception = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]
    flash[:alert] = I18n.t("devise.omniauth_callbacks.failure", kind: OmniAuth::Utils.camelize(failed_strategy.name), reason: exception)
    redirect_to root_path
  end

  private

  def callback_from(provider)
    provider = provider.to_s

    if @user.persisted?
      flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: provider.capitalize)
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.#{provider}_data"] = @user.attributes
      # 新規ユーザー作成
      # redirect_to new_user_registration_url
    end
  end
end
