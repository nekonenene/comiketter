class User < ApplicationRecord
  devise :rememberable, :trackable, :timeoutable, :omniauthable, :omniauth_providers => [:twitter]

  class << self
    # 認証情報を元にユーザー検索、存在しなければ作る
    def from_omniauth(auth)
      find_or_create_by(provider: auth["provider"], uid: auth["uid"]) do |user|
        user.provider = auth["provider"]
        user.uid = auth["uid"]
        user.username = auth["info"]["nickname"]
      end
    end

    def new_with_session(params, session)
      if session["devise.user_attributes"]
        new(session["devise.user_attributes"]) do |user|
          user.attributes = params
        end
      else
        super
      end
    end
  end
end
