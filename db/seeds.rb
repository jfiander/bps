# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Role.create!(name: "admin")

education = Role.create!(name: "education")
events = Role.create!(name: "events")

Role.create!([
  {name: "course", parent: education},
  {name: "seminar", parent: education},
  {name: "calendar", parent: events},
  {name: "vsc", parent: events},
  {name: "store"},
  {name: "photos"},
  {name: "newsletter"}
])
