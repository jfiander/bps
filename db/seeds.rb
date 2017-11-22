admin = Role.create!(name: "admin")
education = Role.create!(name: "education", parent: admin)
events = Role.create!(name: "events", parent: admin)

Role.create!([
  {name: "store", parent: admin},
  {name: "photos", parent: admin},
  {name: "newsletter", parent: admin},
  {name: "course", parent: education},
  {name: "seminar", parent: education},
  {name: "calendar", parent: events},
  {name: "vsc", parent: events}
])

adv_grade = EventCategory.create!(title: "advanced_grade")
elective = EventCategory.create!(title: "elective")
seminar = EventCategory.create!(title: "seminar")
meeting = EventCategory.create!(title: "meeting")

%w[seamanship piloting advanced_piloting junior_navigation navigation].each do |ag|
  EventType.create!(title: ag, event_category: adv_grade)
end

%w[cruise_planning electronic_navigation engine_maintenance marine_communication_systems
   marine_electrical_systems sail weather instructor_development].each do |e|
  EventType.create!(title: e, event_category: elective)
end

%w[boat_handling_under_power advanced_powerboat_handling anchoring boating_on_rivers_locks_and_lakes sail_trim_and_rig_tuning 
   using_gps how_to_use_a_chart basic_coastal_navigation mariners_compass mastering_the_rules_of_the_road marine_radar 
   basic_weather_and_forecasting hurricane_preparation_for_boaters tides_and_currents 
   emergencies_on_board fuel_and_boating partner_in_command man_overboard using_vhf vhf_dsc_marine_radio 
   knots_bends_and_hitches paddle_smart trailering_your_boat 
   crossing_borders].each do |e|
  EventType.create!(title: e, event_category: seminar)
end

%w[rendezvous membership_meeting change_of_watch commanders_ball].each do |e|
  EventType.create!(title: e, event_category: meeting)
end
