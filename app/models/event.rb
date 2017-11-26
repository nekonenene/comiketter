class Event < ApplicationRecord

  has_many :circle_space, dependent: :nullify

end
