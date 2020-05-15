# frozen_string_literal: true

namespace :test_calendar do
  desc 'Clear events from the test calendar'
  task :clear, [:verbose] => :environment do |_task, args|
    GoogleAPI::Calendar.new.clear_test_calendar(verbose: args[:verbose].present?)
  end
end
