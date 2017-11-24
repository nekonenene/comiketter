Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV["TWITTER_CONSUMER_KEY"], ENV["TWITTER_CONSUMER_SECRET"]

  on_failure do |env|
    # 認証キャンセルの場合に /auth/failure へリダイレクト
    OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  end
end
