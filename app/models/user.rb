class User < ApplicationRecord

  CIPHER = "AES-256-CBC"

  def encryptor
    key_len = OpenSSL::Cipher.new(CIPHER).key_len
    key = ActiveSupport::KeyGenerator.new(ENV["SECRET_KEY_BASE"]).generate_key(self.salt, key_len)
    ActiveSupport::MessageEncryptor.new(key, cipher: CIPHER)
  end

  def encrypt_message(message)
    encryptor.encrypt_and_sign(message)
  end

  def decrypt_message(encrypted_message)
    encryptor.decrypt_and_verify(encrypted_message)
  end

  def access_token_secret
    decrypt_message(self.encrypted_access_token_secret)
  end

  class << self
    # 認証情報を元にユーザー検索、存在しなければ作る
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
        user = create_new_user(auth_user, access_token_secret)
      elsif user.handle != auth_user.handle || user.username != auth_user.username
        user.update({
          handle: auth_user.handle,
          username: auth_user.username,
        })
      end

      user
    end

    private

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
  end
end
