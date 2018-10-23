# frozen_string_literal: true

class SlackNotification
  attr_accessor :type, :dryrun, :title, :fallback, :fields, :channel

  def initialize(options = {})
    @channel = validated_channel(options[:channel].to_s)
    @type = validated_type(options[:type])
    @title = options[:title]
    @fallback = options[:fallback]
    @dryrun = options[:dryrun] || Rails.env.test?
    @fields = validated_fields(options[:fields])
  end

  def data
    @data = {}
    @data['title'] = @title || 'Birmingham Power Squadron'
    @data['fallback'] = @fallback || @data['title']
    @data['fields'] = @fields if @fields.present?
    @data['color'] = slack_color
    @data['footer'] = ENV['ASSET_ENVIRONMENT']
    @data
  end

  def notify!
    @dryrun ? data : notifier.post(attachments: [data])
  end

private

  def notifier
    raise "Missing notifier url for #{@channel}." if slack_urls[@channel].blank?

    Slack::Notifier.new(slack_urls[@channel])
  end

  def validated_fields(fields)
    if fields.is_a?(Hash)
      fields = fields_from_hash(fields)
    elsif fields.is_a?(String)
      @title = fields
      fields = []
    elsif !fields.is_a?(Array)
      raise ArgumentError, 'Unsupported fields format.'
    end

    fields.is_a?(Hash) ? fields_from_hash(fields) : fields
  end

  def fields_from_hash(hash)
    hash.map do |title, value|
      { 'title' => title, 'value' => value, 'short' => true }
    end
  end

  def slack_color
    return '#041E42' if @type.blank?

    { success: '#1086FF', info: '#99CEFF', warning: '#FF6600', failure: '#BF0D3E' }[@type]
  end

  def validated_channel(channel = nil)
    default_channel = 'notifications'
    linked_channels = slack_urls.keys
    channel = channel.delete('#')

    return default_channel if channel.blank?
    return channel if channel.in?(linked_channels)

    raise ArgumentError, 'That channel is not linked to this notifier.'
  end

  def slack_urls
    # Find all Slack notifier URLs
    keys = ENV.select { |k, _| k.match?(/SLACK_URL_/) }.keys.map do |k|
      k.gsub('SLACK_URL_', '').downcase
    end

    # Build hash of URLs
    urls = {}
    keys.each { |key| urls[key] = ENV["SLACK_URL_#{key.upcase}"] }
    urls
  end

  def validated_type(type = nil)
    valid_types = %i[success info warning failure]
    return type if type.blank? || type.in?(valid_types)

    raise ArgumentError, 'Unrecognized notification type.'
  end
end
