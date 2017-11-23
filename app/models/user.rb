class User < ApplicationRecord
  class << self
    # 認証情報を元にユーザー検索、存在しなければ作る
    def create_by_response(response)
      # puts response
      provider = response["provider"]
      uid = response["uid"]
      handle = response["info"]["nickname"] # @nekonenene などメンションに使うID
      username = response["info"]["name"] # ハトネコエ などユーザー名
      access_token = response["credentials"]["token"]
      access_token_secret = response["credentials"]["secret"]

      user = find_by(provider: provider, uid: uid)

      if user.nil?
        user = User.create({
          provider: provider,
          uid: uid,
          handle: handle,
          username: username,
          access_token: access_token,
        })
      elsif user.handle != handle || user.username != username
        user = User.update({
          handle: handle,
          username: username,
        })
      end

      user
    end
  end
end
