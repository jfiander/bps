# frozen_string_literal: true

admin = Role.create!(name: 'admin', icon: 'shield-alt')
education = Role.create!(name: 'education', parent: admin, icon: 'graduation-cap')
event = Role.create!(name: 'event', parent: admin, icon: 'calendar-day')
users = Role.create!(name: 'users', parent: admin, icon: 'users')

Role.create!([
  { name: 'page', parent: admin, icon: 'file-alt' },
  { name: 'store', parent: admin, icon: 'shopping-cart' },
  { name: 'photos', parent: admin, icon: 'images' },
  { name: 'newsletter', parent: admin, icon: 'newspaper' },
  { name: 'minutes', parent: admin, icon: 'cabinet-filing' },
  { name: 'roster', parent: admin, icon: 'clipboard-list' },
  { name: 'property', parent: admin, icon: 'boxes' },
  { name: 'float', parent: users, icon: 'file-check' },
  { name: 'course', parent: education, icon: 'users-class' },
  { name: 'seminar', parent: education, icon: 'presentation' },
  { name: 'calendar', parent: event, icon: 'calendar-alt' },
  { name: 'vsc', parent: admin, icon: 'life-ring' },
  { name: 'otw', parent: education, icon: 'ship' }
])

%w[seamanship piloting advanced_piloting junior_navigation navigation].each do |ag|
  EventType.create!(title: ag, event_category: 'advanced_grade')
end

%w[
  cruise_planning electronic_navigation engine_maintenance marine_communication_systems
  marine_electrical_systems sail weather instructor_development
].each do |e|
  EventType.create!(title: e, event_category: 'elective')
end

%w[
  boat_handling_under_power advanced_powerboat_handling anchoring boating_on_rivers_locks_and_lakes
  sail_trim_and_rig_tuning using_gps how_to_use_a_chart basic_coastal_navigation mariners_compass
  mastering_the_rules_of_the_road marine_radar basic_weather_and_forecasting
  hurricane_preparation_for_boaters tides_and_currents emergencies_on_board fuel_and_boating
  partner_in_command man_overboard using_vhf vhf_dsc_marine_radio knots_bends_and_hitches
  paddle_smart trailering_your_boat crossing_borders
].each do |e|
  EventType.create!(title: e, event_category: 'seminar')
end

%w[rendezvous membership_meeting change_of_watch commanders_ball conference].each do |e|
  EventType.create!(title: e, event_category: 'meeting')
end

%w[americas_boating_course pleasure_craft_operator_card cpr_aed].each do |e|
  EventType.create!(title: e, event_category: 'public')
end

%w[home about join vsc education civic history links members welcome requirements user_help].each do |page|
  StaticPage.create!(name: page)
end

%w[commander executive educational administrative secretary treasurer].each do |office|
  BridgeOffice.create!(office: office)
end
