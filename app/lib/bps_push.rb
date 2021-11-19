# frozen_string_literal: true

# Helper for sending push notifications
class BpsPush
  PRIORITIES = {
    lowest: -2,
    low: -1,
    normal: 0,
    high: 1,
    emergency: 2
  }.freeze

  def self.for(user, priority: :normal)
    new(user, priority: priority)
  end

  def self.notify(user, message, title: nil, priority: :normal)
    new(user, priority: priority).notify(message, title: title)
  end

  def initialize(user, priority: :normal)
    raise UserNotRegistered, "User id: #{user.id}" unless user.pushover_token.present?

    @user = user
    @priority = priority.to_s.downcase.to_sym

    validate_user!
  end

  def notify(message, title: nil)
    options = { title: title, priority: PRIORITIES[@priority] }
    options.merge!(expire: 180, retry: 60) if @priority == :emergency

    response = client.notify(@user.pushover_token, message, **options)
    handle_error(response) unless response.ok?

    response # Rushover::Response
  end

  def validate_user!
    client.validate!(@user.pushover_token)
  end

  private

  def client
    @client ||= Rushover::Client.new(ENV['PUSHOVER_APP_TOKEN'])
  end

  def handle_error(response)
    raise ResponseError, response.inspect
  end

  class BpsPushError < StandardError; end
  class UserNotRegistered < BpsPushError; end
  class ResponseError < BpsPushError; end
end
