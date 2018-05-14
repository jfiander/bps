class SlackNotification
  attr_accessor :type, :dryrun, :title, :fallback, :fields

  def initialize(type: nil, dryrun: nil, title: nil, fallback: nil, fields: nil)
    raise 'Missing notifier url.' if ENV['SLACK_NOTIFIER_URL'].blank?

    @type = type
    @title = title
    @fallback = fallback
    @dryrun = dryrun || Rails.env.test?
    @fields = fields.is_a?(Hash) ? fields_from_hash(fields) : fields
    @data = {}
  end

  def data
    validate_fields

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
    Slack::Notifier.new(
      ENV['SLACK_NOTIFIER_URL'],
      channel: '#notifications',
      username: 'BPS Notifier'
    )
  end

  def validate_fields
    if @fields.is_a?(String)
      @title = @fields
      @fields = []
    elsif !@fields.is_a?(Array)
      raise 'Unsupported fields format.'
    end
  end

  def fields_from_hash(hash)
    hash.map do |title, value|
      {
        'title' => title,
        'value' => value,
        'short' => true
      }
    end
  end

  def slack_color
    return '#041E42' if @type.blank?

    {
      success: '#1086FF',
      info: '#99CEFF',
      warning: '#FF6600',
      failure: '#BF0D3E'
    }[@type]
  end
end
