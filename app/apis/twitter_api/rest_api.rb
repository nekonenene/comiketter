class TwitterApi::RestApi

  MAX_REQUESTS_PER_15_MINITUES = 15 # APIで15分間に可能なリクエスト数
  LIMIT_PER_PAGE = 200 # 1ページに取得するデータ数（ちなみにデフォルトは20）

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

  # @param [String] handle_or_uid ユーザーID もしくは uid
  # @return [String, String] フォロワー一覧, エラーメッセージ
  def get_followers(handle_or_uid)
    followers = []
    next_cursor = -1

    begin
      MAX_REQUESTS_PER_15_MINITUES.times do
        attrs = @client.followers(user: handle_or_uid, count: LIMIT_PER_PAGE, skip_status: true, cursor: next_cursor).attrs
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

  # @param [String] handle_or_uid ユーザーID もしくは uid
  # @return [String, String] フレンズ一覧, エラーメッセージ
  def get_friends(handle_or_uid)
    friends = []
    next_cursor = -1

    begin
      MAX_REQUESTS_PER_15_MINITUES.times do
        attrs = @client.friends(user: handle_or_uid, count: LIMIT_PER_PAGE, skip_status: true, cursor: next_cursor).attrs
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
