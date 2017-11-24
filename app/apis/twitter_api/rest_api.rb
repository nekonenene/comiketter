class TwitterApi::RestApi

  MAX_GETTABLE_USERS = 5000 # API で取得可能なフォロワー・フレンズ上限

  # @param [String] access_token
  # @param [String] access_token_secret
  # @return [self]
  def initialize(access_token, access_token_secret)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = access_token
      config.access_token_secret = access_token_secret
    end
  end

  # @param [String] handle ユーザーID
  # @return [String, String] フォロワー一覧, エラーメッセージ
  def get_followers(handle)
    limit = 200
    followers = []
    next_cursor = -1

    begin
      (MAX_GETTABLE_USERS / limit).times do
        attrs = @client.followers(user: handle, count: limit, skip_status: true, cursor: next_cursor).attrs
        followers.concat(attrs[:users])
        next_cursor = attrs[:next_cursor].to_i
        break if next_cursor == 0
      end

    rescue Twitter::Error::TooManyRequests => e
      puts "リクエストしすぎデース", e.message
      return followers, e.message
    end
    return followers, nil
  end

  # @param [String] handle ユーザーID
  # @return [String, String] フレンズ一覧, エラーメッセージ
  def get_friends(handle)
    limit = 200
    friends = []
    next_cursor = -1

    begin
      (MAX_GETTABLE_USERS / limit).times do
        attrs = @client.friends(user: handle, count: limit, skip_status: true, cursor: next_cursor).attrs
        friends.concat(attrs[:users])
        next_cursor = attrs[:next_cursor].to_i
        break if next_cursor == 0
      end

    rescue Twitter::Error::TooManyRequests => e
      puts "リクエストしすぎデース", e.message
      return friends, e.message
    end
    return friends, nil
  end
end
