# == Schema Information
#
# Table name: circle_spaces
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  event_id     :integer
#  day          :integer          unsigned
#  hall_name    :string(32)
#  space_prefix :string(8)
#  space_number :integer          unsigned
#  space_side   :string(8)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Foreign Keys
#
#  fk_events_on_circle_spaces  (event_id => events.id) ON DELETE => nullify ON UPDATE => cascade
#  fk_users_on_circle_spaces   (user_id => users.id) ON DELETE => cascade ON UPDATE => cascade
#

class CircleSpace < ApplicationRecord

  belongs_to :user
  belongs_to :event

end
