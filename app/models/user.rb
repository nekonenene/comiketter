# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  handle                        :string(255)
#  username                      :string(255)
#  provider                      :string(255)
#  uid                           :string(255)
#  access_token                  :string(255)
#  encrypted_access_token_secret :string(255)
#  salt                          :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_users_on_handle  (handle)
#  index_users_on_uid     (provider,uid) UNIQUE
#

class User < ApplicationRecord

  CIPHER = "AES-256-CBC"

  has_many :circle_space, dependent: :destroy

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
        update_user_info_if_need(user, auth_user, access_token_secret)
      end
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

    # 必要であればユーザー情報を更新
    # @param [User] user DB上のユーザー
    # @param [User] auth_user 認証元から取得したユーザー情報
    # @param [access_token_secret] 暗号化されていないaccess_token_secret
    # @return [User]
    def update_user_info_if_need(user, auth_user, access_token_secret)
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
