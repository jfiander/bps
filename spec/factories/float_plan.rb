# frozen_string_literal: true

FactoryBot.define do
  factory :float_plan do
    name 'John Doe'
    phone '123.555.5555'
    boat_type 'Sail'
    subtype 'Schooner'
    hull_color 'Navy'
    trim_color 'White'
    registration_number 'MC 1234 YZ'
    length '75'
    boat_name 'Schoony McSchoonface'
    make 'Awesome'
    model 'Schoonsome'
    year '2175'
    pfds true
    flares true
    mirror true
    horn true
    smoke true
    flashlight true
    raft true
    epirb true
    paddles false
    food true
    water true
    anchor true
    epirb_16 true
    epirb_1215 false
    epirb_406 true
    radio nil
    channels_monitored '16, 64'
    call_sign 'Schoonface'
    leave_from 'Detroit, MI'
    going_to 'Honolulu, HI'
    leave_at '2018-08-01 12:00:00'
    return_at '2019-07-01 12:00:00'
    alert_at '2019-07-20 12:00:00'
    comments 'Ocean voyage -- will advise shore of plan changes regularly.'
    alert_name 'US Coast Guard'
    alert_phone nil

    trait :one_onboard do
      before(:create) do |float_plan|
        onboard = FactoryBot.build(:float_plan_onboard, float_plan: float_plan)
        float_plan.onboard << onboard
      end
    end

    trait :with_engines do
      number_of_engines 1
      engine_type_1 'Diesel'
      engine_type_2 nil
      horse_power 150
      fuel_capacity 250
    end

    trait :with_a_car do
      car_make 'BMW'
      car_model '550 xi'
      car_year '2018'
      car_color 'Black'
      car_license_plate 'SCHOON'
      car_parked_at 'DYC'
    end

    trait :with_a_trailer do
      trailer_license_plate 'A123456'
    end

    factory :float_plan_with_car, traits: %i[one_onboard with_a_car]
    factory :float_plan_with_trailer, traits: %i[one_onboard with_a_trailer]
    factory :float_plan_with_engines, traits: %i[one_onboard with_engines]
  end
end
