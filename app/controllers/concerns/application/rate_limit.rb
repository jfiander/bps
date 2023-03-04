# frozen_string_literal: true

module Application
  module RateLimit
    module ClassMethods
      def rate_limit!(namespace, only: nil, except: nil)
        before_action(only: only, except: except) { rate_limit!(namespace) }
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

  private

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def rate_limit!(namespace, limit: 5, minutes: 5)
      request_time = DateTime.now
      log_path = Rails.root.join("tmp/rate_limits/#{namespace}.log")

      unless File.exist?(log_path)
        FileUtils.mkdir_p(File.dirname(log_path))
        FileUtils.touch(log_path)
        timestamp = request_time.strftime('%Y-%m-%dT%H:%M:%S%Z')
        count = 0
        File.write(log_path, "#{timestamp} #{count}")
      end

      # Check if log is in limit state
      log = File.open(log_path, 'r')
      timestamp, count = log.read.chomp.split
      time = DateTime.parse(timestamp, '%Y-%m-%dT%H:%M:%S%Z')
      count = count.to_i

      if time < (request_time - minutes.minutes)
        # Time window expired - reset
        timestamp = request_time.strftime('%Y-%m-%dT%H:%M:%S%Z')
        count = 1
      else
        # Current time window
        count += 1

        if count > limit
          flash[:alert] = 'Too many recent requests. Please try again later.'
          render(status: :too_many_requests)
          timestamp = DateTime.now.strftime('%Y-%m-%dT%H:%M:%S%Z') # Refresh timestamp
          File.write(log_path, "#{timestamp} #{count}")
          return false
        end
      end

      # Update log and allow request to proceed
      File.write(log_path, "#{timestamp} #{count}")
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
