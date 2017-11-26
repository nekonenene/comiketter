# == Schema Information
#
# Table name: events
#
#  id           :integer          not null, primary key
#  code         :string(255)      not null
#  display_name :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_events_on_code  (code) UNIQUE
#

class Event < ApplicationRecord

  has_many :circle_space, dependent: :nullify

end
