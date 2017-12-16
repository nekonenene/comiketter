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

  validates :uid, uniqueness: { scope: :provider }
  after_commit :create_or_update_circle_space, on: [:create, :update]

  # 配列からユーザーのフォロワー一覧を更新
  # @param [Array<Hash>] followers Twitter APIから取得したフォロワー一覧
  def update_followers(followers)
    users = []
    user_followers = []

    followers.each{ |follower|
      user = User.find_or_new_by_follower_or_friends_api(follower)
      users << user
      user_followers << UserFollower.new(user: self, follower_user: user)
    }

    User.transaction do
      UserFollower.transaction do
        User.import users
        UserFollower.where(user: self).delete_all
        UserFollower.import user_followers
      end
    end

    users.each{ |user|
      user.create_or_update_circle_space
    }
  end

  # 配列からユーザーのフレンズ一覧を更新
  # @param [Array<Hash>] followers Twitter APIから取得したフォローイング一覧
  def update_friends(friends)
    users = []
    user_followers = []

    friends.each{ |friends|
      user = User.find_or_new_by_follower_or_friends_api(friends)
      users << user
      user_followers << UserFollower.new(user: user, follower_user: self)
    }

    User.transaction do
      UserFollower.transaction do
        User.import users
        UserFollower.where(follower_user: self).delete_all
        UserFollower.import user_followers
      end
    end

    users.each{ |user|
      user.create_or_update_circle_space
    }
  end

  # @return [MessageEncryptor]
  def encryptor
    key_len = OpenSSL::Cipher.new(CIPHER).key_len
    key = ActiveSupport::KeyGenerator.new(ENV["SECRET_KEY_BASE"]).generate_key(self.salt, key_len)
    ActiveSupport::MessageEncryptor.new(key, cipher: CIPHER)
  end

  # uuser.salt を基に暗号化をおこなう
  # @param [String] message 生の文字列
  # @return [String] 暗号化された文字列
  def encrypt_message(message)
    encryptor.encrypt_and_sign(message)
  end

  # user.salt を基に復号をおこなう
  # @param [String] encrypted_message 暗号化された文字列
  # @return [String] 復号された文字列
  def decrypt_message(encrypted_message)
    encryptor.decrypt_and_verify(encrypted_message)
  end

  # 生のaccess_token_secretを取得
  # @return [String]
  def access_token_secret
    decrypt_message(self.encrypted_access_token_secret)
  end

  # User が作成・更新されたときに CircleSpace 作成
  def find_or_new_circle_space
    now = Time.zone.now
    if now <= "2017-12-31 16:00".to_time
      CircleSpace.find_or_new_by_username(self.username, event_code: "comike93")
    end
  end

  # User が作成・更新されたときに CircleSpace 作成
  def create_or_update_circle_space
    space = find_or_new_circle_space
    space.save! if space.present?
  end

  class << self
    # 認証情報を元にユーザー検索、存在しなければ作る
    # @param [Hash] response 認証元から取得したユーザー情報
    # @return [User]
    def find_or_create_by_response(response)
      raw_info = response.dig(:extra, :raw_info)
      auth_user_info = {
        provider: response[:provider],
        uid: response[:uid],
        handle: response.dig(:info, :nickname), # @nekonenene などメンションに使うID
        username: response.dig(:info, :name), # ハトネコエ などユーザー名
        icon_url: response.dig(:extra, :raw_info, :profile_image_url_https),
        website_url: response.dig(:extra, :raw_info, :entities, :url, :urls, 0, :expanded_url),
        followers_count: response.dig(:extra, :raw_info, :followers_count),
        friends_count: response.dig(:extra, :raw_info, :friends_count),
        access_token: response.dig(:credentials, :token),
        access_token_secret: response.dig(:credentials, :secret),
      }

      user = User.find_by(provider: auth_user_info[:provider], uid: auth_user_info[:uid])

      if user.nil?
        create_new_user(auth_user_info)
      else
        update_user_info(user, auth_user_info)
      end
    end

    # フォロワー・フレンズのUserモデルをAPI情報から作成または更新
    # @param [Hash] user_info Twitter APIから取得したユーザー情報
    def find_or_new_by_follower_or_friends_api(user_info, provider: "twitter")
      uid = user_info[:id]

      user = User.find_by(provider: provider, uid: uid)
      user = User.new if user.nil?

      user.provider = provider
      user.uid = uid
      user.handle = user_info[:screen_name]
      user.username = user_info[:name]
      user.icon_url = user_info[:profile_image_url_https]
      user.website_url = user_info.dig(:entities, :url, :urls, 0, :expanded_url)
      user.followers_count = user_info[:followers_count]
      user.friends_count = user_info[:friends_count]
      user
    end

    private

    # ユーザーの新規作成
    # @param [Hash] auth_user_info 認証元から取得したユーザー情報
    # @return [User] 作成されたユーザー
    def create_new_user(auth_user_info)
      salt = SecureRandom::hex(64)

      User.transaction do
        user = User.create({
          provider: auth_user_info[:provider],
          uid: auth_user_info[:uid],
          handle: auth_user_info[:handle],
          username: auth_user_info[:username],
          icon_url: auth_user_info[:icon_url],
          website_url: auth_user_info[:website_url],
          followers_count: auth_user_info[:followers_count],
          friends_count: auth_user_info[:friends_count],
          last_signin_at: Time.zone.now,
          access_token: auth_user_info[:access_token],
          salt: salt,
        })

        encrypted_access_token_secret = user.encrypt_message(auth_user_info[:access_token_secret])
        user.update(encrypted_access_token_secret: encrypted_access_token_secret)
        user
      end
    end

    # 認証情報を元にユーザーを更新
    # @param [User] user DB上のユーザー
    # @param [Hash] auth_user_info 認証元から取得したユーザー情報
    # @return [User]
    def update_user_info(user, auth_user_info)
      User.transaction do
        user.update({
          handle: auth_user_info[:handle],
          username: auth_user_info[:username],
          icon_url: auth_user_info[:icon_url],
          website_url: auth_user_info[:website_url],
          followers_count: auth_user_info[:followers_count],
          friends_count: auth_user_info[:friends_count],
          last_signin_at: Time.zone.now,
        })
        update_access_token(user, auth_user_info) if user.access_token != auth_user_info[:access_token]
      end

      user
    end

    # ユーザーのアクセストークン、シークレットを更新
    # @param [User] user DB上のユーザー
    # @param [User] auth_user_info 認証元から取得したユーザー情報
    # @return [User]
    def update_access_token(user, auth_user_info)
      User.transaction do
        if user.salt.nil?
          salt = SecureRandom::hex(64)
          user.update(salt: salt)
        end
        user.update(access_token: auth_user_info[:access_token])
        encrypted_access_token_secret = user.encrypt_message(auth_user_info[:access_token_secret])
        user.update(encrypted_access_token_secret: encrypted_access_token_secret)
      end

      user
    end
  end
end
