# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  handle                        :string(255)
#  username                      :string(255)
#  icon_url                      :string(255)
#  website_url                   :string(255)
#  followers_count               :integer
#  friends_count                 :integer
#  provider                      :string(255)
#  uid                           :string(255)
#  access_token                  :string(255)
#  encrypted_access_token_secret :string(255)
#  salt                          :string(255)
#  last_signin_at                :datetime
#  last_followers_updated_at     :datetime
#  last_friends_updated_at       :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

class User < ApplicationRecord

  CIPHER = "AES-256-CBC"

  has_many :circle_spaces, dependent: :destroy
  has_many :user_follower_users, class_name: "UserFollower", foreign_key: :user_id, dependent: :destroy
  has_many :user_follower_followers, class_name: "UserFollower", foreign_key: :follower_user_id, dependent: :destroy
  has_many :followers, through: :user_follower_users # followers of user
  has_many :friends, through: :user_follower_followers # following users

  def update_followers(followers)
    user_followers = []

    followers.each{ |follower|
      user = User.create_or_update_follower_or_friends(follower)
      user_followers << UserFollower.new(user: self, follower_user: user)
    }

    UserFollower.where(user: self).delete_all
    UserFollower.import user_followers
  end

  def update_friends(friends)
    user_followers = []

    friends.each{ |friends|
      user = User.create_or_update_follower_or_friends(friends)
      user_followers << UserFollower.new(user: user, follower_user: self)
    }

    UserFollower.where(follower_user: self).delete_all
    UserFollower.import user_followers
  end

  # @return [MessageEncryptor]
  def encryptor
    key_len = OpenSSL::Cipher.new(CIPHER).key_len
    key = ActiveSupport::KeyGenerator.new(ENV["SECRET_KEY_BASE"]).generate_key(self.salt, key_len)
    ActiveSupport::MessageEncryptor.new(key, cipher: CIPHER)
  end

  # uuser.salt を基に暗号化をおこなう
  # @param [String] 生の文字列
  # @return [String] 暗号化された文字列
  def encrypt_message(message)
    encryptor.encrypt_and_sign(message)
  end

  # user.salt を基に復号をおこなう
  # @param [String] 暗号化された文字列
  # @return [String] 復号された文字列
  def decrypt_message(encrypted_message)
    encryptor.decrypt_and_verify(encrypted_message)
  end

  # 生のaccess_token_secretを取得
  # @return [String]
  def access_token_secret
    decrypt_message(self.encrypted_access_token_secret)
  end

  class << self
    # 認証情報を元にユーザー検索、存在しなければ作る
    # @param [Hash] response 認証元から取得したユーザー情報
    # @return [User]
    def find_or_create_by_response(response)
      auth_user = User.new
      auth_user.provider = response["provider"]
      auth_user.uid = response["uid"]
      auth_user.handle = response["info"]["nickname"] # @nekonenene などメンションに使うID
      auth_user.username = response["info"]["name"] # ハトネコエ などユーザー名
      auth_user.access_token = response["credentials"]["token"]
      access_token_secret = response["credentials"]["secret"]

      user = User.find_by(provider: auth_user.provider, uid: auth_user.uid)

      if user.nil?
        create_new_user(auth_user, access_token_secret)
      else
        update_user_info(user, auth_user, access_token_secret)
      end
    end

    # フォロワー・フレンズのUserモデルをAPI情報から作成または更新
    # @param [Hash] user_info Twitter APIから取得したユーザー情報
    def create_or_update_follower_or_friends(user_info, provider: "twitter")
      uid = user_info[:id]
      user = User.find_by(provider: provider, uid: uid)

      if user.nil?
        user = User.create({
          provider: provider,
          uid: uid,
          handle: user_info[:screen_name],
          username: user_info[:name],
          icon_url: user_info[:profile_image_url_https],
          website_url: user_info[:url],
          followers_count: user_info[:followers_count],
          friends_count: user_info[:friends_count],
        })
      else
        user.update({
          handle: user_info[:screen_name],
          username: user_info[:name],
          icon_url: user_info[:profile_image_url_https],
          website_url: user_info[:url],
          followers_count: user_info[:followers_count],
          friends_count: user_info[:friends_count],
        })
      end
      user
    end

    private

    # ユーザーの新規作成
    # @param [User] auth_user 認証元から取得したユーザー情報
    # @param [access_token_secret] 暗号化されていないaccess_token_secret
    # @return [User] 作成されたユーザー
    def create_new_user(auth_user, access_token_secret)
      salt = SecureRandom::hex(64)

      User.transaction do
        user = User.create({
          provider: auth_user.provider,
          uid: auth_user.uid,
          handle: auth_user.handle,
          username: auth_user.username,
          access_token: auth_user.access_token,
          salt: salt,
        })

        encrypted_access_token_secret = user.encrypt_message(access_token_secret)
        user.update(encrypted_access_token_secret: encrypted_access_token_secret)
        user
      end
    end

    # 認証情報を元にユーザーを更新
    # @param [User] user DB上のユーザー
    # @param [User] auth_user 認証元から取得したユーザー情報
    # @param [access_token_secret] 暗号化されていないaccess_token_secret
    # @return [User]
    def update_user_info(user, auth_user, access_token_secret)
      user.update(last_signin_at: Time.zone.now)
      user.update(handle: auth_user.handle) if user.handle != auth_user.handle
      user.update(username: auth_user.username) if user.username != auth_user.username
      update_access_token(user, auth_user, access_token_secret) if user.access_token != auth_user.access_token
      user
    end

    # ユーザーのアクセストークン、シークレットを更新
    # @param [User] user DB上のユーザー
    # @param [User] auth_user 認証元から取得したユーザー情報
    # @param [access_token_secret] 暗号化されていないaccess_token_secret
    # @return [User]
    def update_access_token(user, auth_user, access_token_secret)
      User.transaction do
        if user.salt.nil?
          salt = SecureRandom::hex(64)
          user.update(salt: salt)
        end
        user.update(access_token: auth_user.access_token)
        encrypted_access_token_secret = user.encrypt_message(access_token_secret)
        user.update(encrypted_access_token_secret: encrypted_access_token_secret)
        user
      end
    end
  end
end
