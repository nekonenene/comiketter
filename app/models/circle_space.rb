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
#  space_number :string(8)
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

  validates :user_id, presence: true

  class << self
    def find_or_new_by_username(username, event_code: nil)
      raise "event_code should not be nil" if event_code.nil?

      space_info = CircleSpaceService.analyze_space_from_username(username)

      if space_info[:space_prefix].present? && space_info[:space_number].present?
        event = Event.find_by(code: event_code)
        begin
          user = User.find_by!(username: username)
        rescue ActiveRecord::RecordNotFound => e
          puts e.inspect
          return nil
        end

        space = CircleSpace.find_by(user: user, event: event)
        space = CircleSpace.new if space.nil?

        space.user = user
        space.event = event
        space.day = space_info[:day]
        space.hall_name = space_info[:hall_name]
        space.space_prefix = space_info[:space_prefix]
        space.space_number = space_info[:space_number]
        space.space_side = space_info[:space_side]
        space
      end
    end
  end
end
