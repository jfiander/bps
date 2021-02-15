# frozen_string_literal: true

# Helper for sending SMS messages
#
# Docs: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SNS/Client.html#publish-instance_method
class BpsSMS
  ALLOWED_TYPES = %i[promotional transactional].freeze

  # Allow the public API to be called directly on the class
  class << self
    %w[
      publish broadcast opt_in! create_topic
      subscribe confirm_subscription unsubscribe
    ].each do |method|
      define_method(method) { |*args| new.send(method, *args) }
    end
  end

  # Send a message
  #
  # One of these destination options is required:
  # topic_arn: 'topicARN',
  # target_arn: 'String',
  # phone_number: 'number'
  def publish(number, message, type: :promotional)
    return if opted_out?(number)

    client.publish({
      phone_number: number,
      message: message,
      message_attributes: message_attributes(type)
    })
  end

  def broadcast(topic_arn, message)
    client.publish({
      topic_arn: topic_arn,
      message: message,
      message_attributes: message_attributes(:promotional)
    })
  end

  # Only call this with the user's permission
  def opt_in!(number)
    client.opt_in_phone_number({
      phone_number: number
    })
  end

  def create_topic(name, display_name = nil)
    client.create_topic({
      name: name,
      attributes: {
        'DisplayName' => display_name || name
      }
    })
  end

  def subscribe(topic_arn, number)
    client.subscribe({
      topic_arn: topic_arn,
      protocol: 'sms',
      endpoint: number,
      return_subscription_arn: true
    })
  end

  # Only required for HTTP/S or Email subscriptions
  def confirm_subscription(topic_arn, token)
    client.confirm_subscription({
      topic_arn: topic_arn,
      token: token,
      authenticate_on_unsubscribe: 'true'
    })
  end

  def unsubscribe(subscription_arn)
    client.unsubscribe({
      subscription_arn: subscription_arn
    })
  end

private

  def client
    @client ||= Aws::SNS::Client.new(
      region: 'us-east-1',
      credentials: Aws::Credentials.new(
        Rails.application.secrets[:s3_access_key],
        Rails.application.secrets[:s3_secret]
      )
    )
  end

  def opted_out?(number)
    client.check_if_phone_number_is_opted_out({
      phone_number: number
    }).is_opted_out
  end

  def message_attributes(type)
    {
      'AWS.MM.SMS.OriginationNumber' => origination_number,
      'AWS.SNS.SMS.SMSType' => sms_type(type)
    }
  end

  def origination_number
    {
      data_type: 'String',
      string_value: ENV['SMS_ORIGINATION_NUMBER']
    }
  end

  def sms_type(type)
    raise ArgumentError, "Unknown SMS type: #{type}" unless type.in?(ALLOWED_TYPES)

    {
      data_type: 'String',
      string_value: type.to_s.titleize
    }
  end
end
