# frozen_string_literal: true

# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
require 'simplecov'
require 'brakeman'
require 'google_api'

SimpleCov.start('rails') do
  add_group 'Services', 'app/services'
  add_group 'Channels', 'app/channels'

  # Not application code
  add_filter '/spec'
  add_filter '/config'
  add_filter '/lib'
  add_filter '/app/mailers/previews'

  # Exclude controller code
  add_filter '/app/controllers'

  # Exclude job code
  add_filter '/app/jobs'

  # Exclude static view-oriented helper code
  add_filter '/app/helpers/application_helper.rb'
  add_filter '/app/helpers/menu_helper.rb'
  add_filter '/app/helpers/events_action_links_helper.rb'
  add_filter '/app/helpers/view_helper.rb'
  add_filter '/app/helpers/markdown_helper.rb'
  add_filter '/app/helpers/braintree_helper.rb'
  add_filter '/app/helpers/user_helper.rb'
  add_filter '/app/helpers/user_list_helper.rb'
  add_filter '/app/helpers/receipt_helper.rb'
  add_filter '/app/helpers/signal_flags_helper.rb'

  # Config code located in app/helpers
  add_filter '/app/helpers/devise_helper.rb'

  # Invariant code
  ## used for configuring API access
  add_filter '/app/models/concerns/payment/braintree_methods.rb'
  add_filter '/app/models/concerns/payment/model_configs.rb'
  add_filter '/app/models/concerns/user/push.rb'
  add_filter '/app/models/concerns/excom.rb'
  add_filter '/app/lib/bps/sms.rb'
  add_filter '/app/lib/bps/push.rb'
  ## used for API access to National
  add_filter '/app/services/automatic_update.rb'
  add_filter '/app/services/automatic_update/'
  ## used for configuring regular meetings
  add_filter '/app/lib/bps/regular_meetings.rb'
  ## used for fetching git information
  add_filter '/app/lib/bps/git_info.rb'
  ## used to improve markdown formatting
  add_filter '/app/lib/target_blank_renderer.rb'
  add_filter '/app/lib/parsed_markdown.rb'
  add_filter '/app/lib/parsed_markdown/parsers.rb'
end
SimpleCov.minimum_coverage(100)

def test_image(width, height)
  MiniMagick::Tool::Convert.new do |i|
    i.size "#{width}x#{height}"
    i.xc 'white'
    i << 'tmp/run/test_image.jpg'
  end

  'tmp/run/test_image.jpg'
end

# Put the officers in scope before the expect call with:
# before(:each) { generic_seo_and_ao }
# then refer to the appropriate officer as:
# generic_seo_and_ao[:seo] # .user
def generic_seo_and_ao
  if (seo = BridgeOffice.find_by(office: 'educational')).blank?
    seo = FactoryBot.create(:bridge_office, office: 'educational')
  end

  if (ao = BridgeOffice.find_by(office: 'administrative')).blank?
    ao = FactoryBot.create(:bridge_office, office: 'administrative')
  end

  { seo: seo, ao: ao }
end

def assign_bridge_office(office, user)
  if (bridge_office = BridgeOffice.find_by(office: office)).blank?
    bridge_office = FactoryBot.create(:bridge_office, office: office)
  end

  bridge_office.update(user: user)
end

GoogleAPI.mock!

module BPS
  class SMS
    def create_topic
      MockTopicResponse.new(SecureRandom.hex(16))
    end

    MockTopicResponse = Struct.new(:topic_arn)
  end
end

RSpec::Matchers.define :contain_and_match do |*expected|
  match do |actual|
    expected.all? do |pattern|
      if pattern.is_a?(Regexp)
        actual.match?(pattern)
      else
        actual.include?(pattern)
      end
    end
  end

  failure_message do |actual|
    "expected that #{actual} would contain or match #{expected}"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not contain or match #{expected}"
  end
end

RSpec::Matchers.define :contain_mail_headers do |**expected|
  match do |actual|
    expected.all? do |key, value|
      actual_header = actual.send(key)

      if actual_header.is_a?(Array)
        actual_header.sort == value.sort
      else
        actual_header == value
      end
    end
  end

  failure_message do |actual|
    hash = expected.keys.index_with { |k| actual.send(k) }
    "expected that #{hash} would match #{expected}"
  end
end

def register(event = nil, user: nil, email: nil, save: true)
  event ||= FactoryBot.create(:event)
  user = FactoryBot.create(:user) if user.blank? && email.blank?
  reg = FactoryBot.build(:registration, event: event, user: user, email: email)
  reg.save! if save

  [reg, nil]
end

def run_brakeman
  example_group = RSpec.describe('Brakeman Issues')
  puts "\n\nBrakeman report available here: ./tmp/brakeman.html"
  example = brakeman_example(example_group)
  example_group.run
  return if example.execution_result.status == :passed

  RSpec.configuration.reporter.example_failed(example)
end

def brakeman_example(example_group)
  example_group.example('must have 0 Critical Security Issues') do
    result = Brakeman.run app_path: Rails.root.to_s, output_files: ['tmp/brakeman.html']
    serious = result.warnings.count { |w| w.confidence == 0 }
    puts "\nBrakeman Result:\n  Critical Security Issues = #{serious}"
    expect(serious).to eq 0
  end
end

def clear_test_calendar
  puts "\n\n*** Specs complete! Clearing test calendar..."
  GoogleAPI::Calendar.new.clear_test_calendar
rescue Google::Apis::ClientError
  nil
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'tmp/run/failures.txt'

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    FileUtils.mkdir_p(Rails.root.join('tmp/run'))
  end

  config.after do
    Event.where.not(google_calendar_event_id: nil)&.map(&:unbook!)
  end

  config.after(:suite) do
    run_brakeman if ENV['RUN_BRAKEMAN'] == 'true'

    DatabaseCleaner.clean_with(:truncation)
    Dir[Rails.root.join('tmp/run/**/*')].each { |file| File.delete(file) }

    # clear_test_calendar if ENV['AUTO_CLEAR_CALENDAR'] == 'true'

    true
  end

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.
  #   # This allows you to limit a spec run to individual examples or groups
  #   # you care about by tagging them with `:focus` metadata. When nothing
  #   # is tagged with `:focus`, all examples get run. RSpec also provides
  #   # aliases for `it`, `describe`, and `context` that include `:focus`
  #   # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  #   config.filter_run_when_matching :focus
  #
  #   # Allows RSpec to persist some state between runs in order to support
  #   # the `--only-failures` and `--next-failure` CLI options. We recommend
  #   # you configure your source control system to ignore this file.
  #   config.example_status_persistence_file_path = "spec/examples.txt"
  #
  #   # Limits the available syntax to the non-monkey patched syntax that is
  #   # recommended. For more details, see:
  #   #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  #   config.disable_monkey_patching!
  #
  #   # Many RSpec users commonly either run the entire suite or an individual
  #   # file, and it's useful to allow more verbose output when running an
  #   # individual spec file.
  #   if config.files_to_run.one?
  #     # Use the documentation formatter for detailed output,
  #     # unless a formatter has already been configured
  #     # (e.g. via a command-line flag).
  #     config.default_formatter = "doc"
  #   end
  #
  #   # Print the 10 slowest examples and example groups at the
  #   # end of the spec run, to help surface which specs are running
  #   # particularly slow.
  #   config.profile_examples = 10
  #
  #   # Run specs in random order to surface order dependencies. If you find an
  #   # order dependency and want to debug it, you can fix the order by providing
  #   # the seed, which is printed after each run.
  #   #     --seed 1234
  #   config.order = :random
  #
  #   # Seed global randomization in this process using the `--seed` CLI option.
  #   # Setting this allows you to use `--seed` to deterministically reproduce
  #   # test failures related to randomization by passing the same `--seed` value
  #   # as the one that triggered the failure.
  #   Kernel.srand config.seed
end
