class User < ApplicationRecord
  class << self
    # 認証情報を元にユーザー検索、存在しなければ作る
    def from_omniauth(auth)
      puts "1############################################"
      puts auth
      puts "############################################"
      find_or_create_by(provider: auth["provider"], uid: auth["uid"]) do |user|
        user.provider = auth["provider"]
        user.uid = auth["uid"]
        user.username = auth["info"]["nickname"]
      end
    end

    def new_with_session(params, session)
      puts "2############################################"
      puts params
      puts "############################################"
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
