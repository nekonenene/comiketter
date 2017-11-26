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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
