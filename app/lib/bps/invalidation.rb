# frozen_string_literal: true

module BPS
  class Invalidation
    GLOBAL_DISTROS ||= %i[static seo].freeze
    AVAILABLE_DISTROS ||= (GLOBAL_DISTROS + %i[files bilge photos]).freeze

    attr_reader :alias_name, :keys, :caller_reference

    def self.submit(alias_name, *new_keys, caller_reference: nil)
      invalidation = new(alias_name, new_keys, caller_reference: caller_reference)

      { invalidation: invalidation, result: invalidation.submit }
    end

    def self.list(alias_name, verbose: true)
      invalidation = new(alias_name)

      { invalidation: invalidation, result: invalidation.list(verbose: verbose) }
    end

    def self.pending(alias_name)
      invalidation = new(alias_name)

      { invalidation: invalidation, result: invalidation.pending }
    end

    def initialize(alias_name, *new_keys, caller_reference: nil)
      @alias_name = alias_name.to_sym
      add_keys(*new_keys)
      @caller_reference = caller_reference || new_caller_reference
      @submitted = false
    end

    # If you re-submit the same instance, or store the caller_reference and initialize a new one
    # with it, this will instead get the status of that invalidation request.
    def submit
      raise 'No keys specified.' unless @keys.size.positive?

      @submitted = true
      cloud_front.create_invalidation(
        distribution_id: find_distro_id,
        invalidation_batch: {
          paths: { quantity: @keys.size, items: @keys },
          caller_reference: @caller_reference
        }
      )
    end

    def add_keys(*new_keys)
      return if @submitted

      @keys ||= []
      @keys += new_keys.flatten.map { |k| validate_key!(k) }
    end

    def list(verbose: true)
      result = cloud_front.list_invalidations(
        distribution_id: find_distro_id
      )

      puts(result.invalidation_list.items.map { |l| "#{l.id} -> #{l.status}" }, '') if verbose

      result
    end

    def pending
      list(verbose: false).invalidation_list.items.reject { |l| l.status == 'Completed' }
    end

    def pending?
      pending.any?
    end

  private

    def cloud_front
      Aws::CloudFront::Client.new(cloud_front_attributes)
    end

    def cloud_front_attributes
      attributes = { region: 'us-east-2' }

      unless BPS::Application.deployed?
        attributes.merge!(
          credentials: Aws::Credentials.new(
            ENV.fetch('AWS_ACCESS_KEY', nil),
            ENV.fetch('AWS_SECRET', nil)
          )
        )
      end

      attributes
    end

    def find_distro_id
      cloud_front.list_distributions.distribution_list.items.select do |distro|
        distro.aliases.items.first == "#{subdomain}.bpsd9.org"
      end.first&.id
    end

    def subdomain
      raise 'Unrecognized distribution alias.' unless @alias_name.in?(AVAILABLE_DISTROS)
      return @alias_name if @alias_name.in?(GLOBAL_DISTROS)

      return @alias_name.to_s if ENV['ASSET_ENVIRONMENT'] == 'production'

      "#{@alias_name}.#{ENV.fetch('ASSET_ENVIRONMENT', nil)}"
    end

    def new_caller_reference
      "#{Time.new.to_i}-#{SecureRandom.hex(8)}"
    end

    def validate_key!(key)
      return key if valid_key?(key)
      return "/#{key}" if valid_key?(key, leading_slash: false)
      return "#{key}*" if valid_key?(key, trailing_slash: true)
      return "/#{key}*" if valid_key?(key, leading_slash: false, trailing_slash: true)

      raise "Invalid key detected: #{key}"
    end

    def valid_key?(key, leading_slash: true, trailing_slash: false)
      key_chunk = '[0-9a-zA-Z\-_.*]'
      lead = leading_slash ? '/' : ''
      trail = trailing_slash ? '/' : ''

      match = key.match?(%r{\A#{lead}#{key_chunk}+(/?#{key_chunk})*#{trail}\z})
      max_one_wildcard = key.gsub(/[^*]/, '').in?(['', '*'])
      match && max_one_wildcard
    end
  end
end
