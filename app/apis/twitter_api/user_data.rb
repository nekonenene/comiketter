class TwitterApi::UserData

  def initialize(user)
    @user = user
    @api = TwitterApi::RestApi.new(user.access_token, user.access_token_secret)
  end

  # フォロワー（フォローしてくれてる人）
  def followers
    if @followers.nil?
      followers, err = @api.get_followers(@user.uid)
      @followers = followers if err.nil?
    end
    @followers
  end

  # フレンズ（フォローしてる人）
  def friends
    if @friends.nil?
      friends, err = @api.get_friends(@user.uid)
      @friends = friends if err.nil?
    end
    @friends
  end

end
