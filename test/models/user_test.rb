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

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "load fixture?" do
    assert_equal(1, users(:signin_user_1).id)
  end

  test "encrypt and decrypt" do
    user = users(:signin_user_1)

    encrypted = user.encrypt_message("test")
    assert(encrypted.kind_of? String)

    decrypted = user.decrypt_message(encrypted)
    assert_equal("test", decrypted)
  end

  test "add empty followers or friends" do
    user = users(:signin_user_1)

    assert_equal(0, user.followers.count)
    assert_equal(0, user.friends.count)

    user.update_followers([])
    user.update_friends([])

    assert_equal(0, user.followers.count)
    assert_equal(0, user.friends.count)
  end

  test "add followers" do
    user = users(:signin_user_1)

    UserFollower.create!(user: user, follower_user: users(:participant_1))
    assert_equal(1, user.followers.count)
  end

  test "add friends" do
    user = users(:signin_user_1)

    UserFollower.create!(user: users(:participant_1), follower_user: user)
    UserFollower.create!(user: users(:participant_2), follower_user: user)
    assert_equal(2, user.friends.count)
  end

  test "add comike93 space when create user" do
    Timecop.travel("2017-12-28") do
      users_count = User.count
      spaces_count = CircleSpace.count

      user = User.create!(handle: "test", username: "AAA@2日目 A13a")

      assert_equal(1, User.count - users_count)
      assert_equal(1, CircleSpace.count - spaces_count)
      assert_equal(1, user.circle_spaces.count)
      assert_equal("13", user.circle_spaces.last.space_number)

      # ユーザー情報が更新されたとき
      user.update!(username: "AAA@3日目 A33b")

      assert_equal(1, user.circle_spaces.count)
      assert_equal("33", user.circle_spaces.last.space_number)
    end
  end
end
