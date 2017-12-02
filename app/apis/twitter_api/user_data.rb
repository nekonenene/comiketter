class TwitterApi::UserData

  API_REQUEST_INTERVAL_MINUTES = 15

  def initialize(user)
    @user = user
    @api = TwitterApi::RestApi.new(user.access_token, user.access_token_secret)
  end

  # フォロワー（フォローしてくれてる人）を取得
  # @param [Boolean] force_update 指定分数経っていなくともAPIアクセスを再実行
  def update_followers(force_update: false)
    last_updated_at = @user.last_followers_updated_at
    if last_updated_at.nil? || last_updated_at < API_REQUEST_INTERVAL_MINUTES.minutes.ago || force_update
      followers, err = @api.get_followers(@user.uid)
      if err.nil?
        User.transaction do
          @user.update_followers(followers)
          @user.update(last_followers_updated_at: Time.zone.now)
        end
      end
    end

    return followers, err
  end

  # フレンズ（フォローしてる人）を取得
  # @param [Boolean] force_update 指定分数経っていなくともAPIアクセスを再実行
  def update_friends(force_update: false)
    last_updated_at = @user.last_friends_updated_at
    if last_updated_at.nil? || last_updated_at < API_REQUEST_INTERVAL_MINUTES.minutes.ago || force_update
      friends, err = @api.get_friends(@user.uid)
      if err.nil?
        User.transaction do
          @user.update_friends(friends)
          @user.update(last_friends_updated_at: Time.zone.now)
        end
      end
    end

    return friends, err
  end

end
