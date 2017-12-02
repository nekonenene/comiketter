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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
