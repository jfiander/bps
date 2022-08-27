# frozen_string_literal: true

# Helper for sending SMS messages
#
# Docs: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SNS/Client.html#publish-instance_method
module BPS
  class SMS
    ALLOWED_TYPES = %i[promotional transactional].freeze

    class << self
      # Allow the public API to be called directly on the class
      API_METHODS = %w[
        publish broadcast opt_in! create_topic delete_topic
        subscribe confirm_subscription unsubscribe
      ].freeze
      delegate(*API_METHODS, to: :new)

      # Ensure US/Canada country code
      def validate_number(number)
        pattern = /^(?:\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})$/

        raise "Invalid phone number to subscribe: #{number}" unless (match = number&.match(pattern))

        "+1#{match[1]}#{match[2]}#{match[3]}"
      end
    end

    # Send a message
    #
    # One of these destination options is required:
    # topic_arn: 'topicARN',
    # target_arn: 'String',
    # phone_number: 'number'
    def publish(number, message, type: :transactional)
      return if opted_out?(number)

      client.publish({
        phone_number: BPS::SMS.validate_number(number),
        message: message,
        message_attributes: message_attributes(type)
      })
    end

    def broadcast(topic_arn, message)
      client.publish({
        topic_arn: topic_arn,
        message: message,
        message_attributes: message_attributes(:transactional)
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
        name: "#{ENV['ASSET_ENVIRONMENT']}-#{name}",
        attributes: {
          'DisplayName' => display_name || name
        },
        tags: [
          { key: 'Environment', value: ENV['ASSET_ENVIRONMENT'] },
          { key: 'CreatedAt', value: Time.now.to_s }
        ]
      })
    end

    def delete_topic(topic_arn)
      client.delete_topic({
        topic_arn: topic_arn
      })
    end

    def subscribe(topic_arn, number)
      client.subscribe({
        topic_arn: topic_arn,
        protocol: 'sms',
        endpoint: BPS::SMS.validate_number(number),
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
      @client ||= Aws::SNS::Client.new(sns_attributes)
    end

    def sns_attributes
      attributes = { region: 'us-east-1' }

      unless BPS::Application.deployed?
        attributes.merge!(
          credentials: Aws::Credentials.new(
            ENV['AWS_ACCESS_KEY'],
            ENV['AWS_SECRET']
          )
        )
      end

      attributes
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
        string_value: BPS::SMS.validate_number(ENV['SMS_ORIGINATION_NUMBER'])
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
end
