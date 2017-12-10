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

  class << self
    def create_or_update_by_username(username, event_code: "comike93")
      space_info = CircleSpaceService.analyze_space_from_username(username)

      if space_info[:space_prefix].present? && space_info[:space_number].present?
        event = Event.find_by(code: event_code)
        user = User.find_by!(username: username)
        space = CircleSpace.find_by(user: user, event: event)

        if space.nil?
          CircleSpace.create({
            user: user,
            event: event,
            day: space_info[:day],
            hall_name: space_info[:hall_name],
            space_prefix: space_info[:space_prefix],
            space_number: space_info[:space_number],
            space_side: space_info[:space_side],
          })
        else
          space.update({
            day: space_info[:day],
            hall_name: space_info[:hall_name],
            space_prefix: space_info[:space_prefix],
            space_number: space_info[:space_number],
            space_side: space_info[:space_side],
          })
        end
      end
    end
  end
end
