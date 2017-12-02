# == Schema Information
#
# Table name: user_followers
#
#  id               :integer          not null, primary key
#  user_id          :integer          not null
#  follower_user_id :integer          not null
#
# Foreign Keys
#
#  fk_follower_users_on_user_followers  (follower_user_id => users.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_users_on_user_followers           (user_id => users.id) ON DELETE => cascade ON UPDATE => cascade
#

class UserFollower < ApplicationRecord

  belongs_to :user
  belongs_to :friend, class_name: "User", foreign_key: :user_id
  belongs_to :follower_user, class_name: "User"
  belongs_to :follower, class_name: "User", foreign_key: :follower_user_id

end
