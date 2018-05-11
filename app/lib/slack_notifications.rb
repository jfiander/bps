module SlackNotifications
  def self.notifier
    raise 'Missing notifier url.' if ENV['SLACK_NOTIFIER_URL'].blank?

    Slack::Notifier.new(
      ENV['SLACK_NOTIFIER_URL'],
      channel: '#notifications',
      username: 'BPS Notifier'
    )
  end

  def self.notify(data: {}, type: nil, dryrun: Rails.env.test?)
    color = slack_color(type)

    if data.is_a?(String)
      data = { 'title' => data }
    elsif !data.is_a?(Hash)
      raise 'Unsupported data format.'
    end

    data.deep_stringify_keys!
    data['title'] ||= 'Birmingham Power Squadron'
    data['fallback'] ||= data['title']
    data['color'] ||= color
    data['footer'] = ENV['ASSET_ENVIRONMENT']

    dryrun ? data : notifier.post(attachments: [data])
  end

  def self.blank
    {
      'fallback' => 'Message text.',
      'title'    => 'Message Title',
      'fields' => [
        {
          'title' => 'Field title',
          'value' => 'Field value',
          'short' => true
        }
      ]
    }
  end

  private

  def self.slack_color(type = nil)
    return '#041E42' if type.blank?

    {
      success: '#1086FF',
      info: '#99CEFF',
      warning: '#FF6600',
      failure: '#BF0D3E'
    }[type]
  end
end
