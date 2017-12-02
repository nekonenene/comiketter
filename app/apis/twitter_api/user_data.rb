class TwitterApi::UserData

  API_REQUEST_INTERVAL_MINUTES = 15

  def initialize(user)
    @user = user
    @api = TwitterApi::RestApi.new(user.access_token, user.access_token_secret)
  end

  # フォロワー（フォローしてくれてる人）を取得
  # @param [Boolean] force_access 指定分数経っていなくともAPIアクセスを再実行
  def followers(force_access: false)
    last_updated_at = @user.last_followers_updated_at
    if last_updated_at.nil? || last_updated_at < API_REQUEST_INTERVAL_MINUTES.minutes.ago || force_access
      puts "**** start API access for followers *****" # TODO: あとで消す
      followers, err = @api.get_followers(@user.uid)
      if err.nil?
        @followers = followers
        @user.update(last_followers_updated_at: Time.zone.now)
      end
    end
    @followers
  end

  # フレンズ（フォローしてる人）を取得
  # @param [Boolean] force_access 指定分数経っていなくともAPIアクセスを再実行
  def friends(force_access: false)
    last_updated_at = @user.last_friends_updated_at
    if last_updated_at.nil? || last_updated_at < API_REQUEST_INTERVAL_MINUTES.minutes.ago || force_access
      puts "**** start API access for friends *****" # TODO: あとで消す
      friends, err = @api.get_friends(@user.uid)
      if err.nil?
        @friends = friends
        @user.update(last_friends_updated_at: Time.zone.now)
      end
    end
    @friends
  end

end
