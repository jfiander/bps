# frozen_string_literal: true

# Helper for sending SMS messages
#
# Docs: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SNS/Client.html#publish-instance_method
class BpsSMS
  ALLOWED_TYPES = %i[promotional transactional].freeze

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
      message_attributes: {
        'String' => string(message),
        'AWS.MM.SMS.OriginationNumber' => origination_number,
        'AWS.SNS.SMS.SMSType' => sms_type(type)
      }
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

  def string(message)
    {
      data_type: 'String',
      string_value: message
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
