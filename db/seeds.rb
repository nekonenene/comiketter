# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

events = [
  {code: "comike93", display_name: "コミックマーケット93", start_date: "2017-12-29".to_date, days: 3},
  {code: "comike95", display_name: "コミックマーケット95", start_date: "2018-12-29".to_date, days: 3},
]

events.each { |event|
  ev = Event.find_or_initialize_by(code: event[:code])
  ev.update_attributes({
    display_name: event[:display_name],
    start_date: event[:start_date],
    days: event[:days] || 1,
  })
}
