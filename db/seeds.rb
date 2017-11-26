# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

events = [
  {code: "comike93", display_name: "コミックマーケット93"}, # 2017冬
]

events.each { |event|
  Event.create(code: event[:code], display_name: event[:display_name]) if Event.find_by(code: event[:code]).nil?
}
