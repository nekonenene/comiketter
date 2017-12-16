# == Schema Information
#
# Table name: events
#
#  id           :integer          not null, primary key
#  code         :string(255)      not null
#  display_name :string(255)
#  start_date   :date
#  days         :integer          default(1), unsigned
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Event < ApplicationRecord

  has_many :circle_spaces, dependent: :nullify

  validates :code, presence: true

end
