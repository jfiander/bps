# frozen_string_literal: true

# Helper for accessing environmented S3 buckets and CloudFront links
module BPS
  class S3
    VALID_BUCKETS = %i[files photos bilge static seo floatplans automatic_updates].freeze
    GLOBAL_BUCKETS = %i[seo automatic_updates].freeze

    attr_reader :bucket

    def initialize(bucket)
      @environment = ENV['ASSET_ENVIRONMENT'].to_sym
      @bucket = bucket.to_sym
      prepare_bucket
    end

    def link(key, signed: false, expires_at: nil)
      sign?(signed: signed) ? signed_link(key, expires_at) : cf_link(key)
    end

    def list(prefix = '')
      s3.objects(prefix: prefix)
    end

    delegate :object, to: :s3

    def has?(key)
      object(key)&.exists?
    end

    def download(key)
      object(key).get.body.read
    end

    def upload(file:, key:, content_type: nil)
      file = File.open(file, 'rb') if file.is_a?(String) || file.is_a?(Pathname)

      object(key).upload_file(file.path, content_type: content_type)
    end

    def move(key, new_key)
      object(key).move_to("#{full_bucket}/#{new_key}")
    end

    def remove_object(key)
      object(key).delete
    end

    def full_bucket
      @full_bucket ||= ['bps', @environment, @bucket].compact.join('-').gsub('_', '-')
    end

  private

    def s3
      @s3 ||= Aws::S3::Resource.new(s3_attributes).bucket(full_bucket)
    end

    def s3_attributes
      attributes = { region: 'us-east-2' }

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

    def prepare_bucket
      raise 'Invalid bucket.' unless @bucket.in?(VALID_BUCKETS)

      @endpoint = @bucket
      @environment = nil if @bucket.in?(GLOBAL_BUCKETS)
      return unless @bucket == :static

      @endpoint = @environment = :static
      @bucket = :files
    end

    def cf_link(key)
      "https://#{cf_host}/#{key}"
    end

    def cf_host
      @cf_host ||= "#{cf_subdomain}.bpsd9.org"
    end

    def cf_subdomain
      first = @endpoint
      second = ENV['ASSET_ENVIRONMENT'] unless single_subdomain?

      [first, second].compact.join('.')
    end

    def single_subdomain?
      @endpoint.in?(%i[seo static]) || ENV['ASSET_ENVIRONMENT'] == 'production'
    end

    def sign?(signed: false)
      return true if @bucket.in?(%i[seo files bilge]) && @environment != :static

      signed
    end

    def signed_link(key, expires_at = nil)
      expires_at ||= 1.hour.from_now
      cf_signer.signed_url(cf_link(key), expires: expires_at)
    end

    def cf_signer
      @cf_signer ||= Aws::CloudFront::UrlSigner.new(
        key_pair_id: ENV['CF_KEYPAIR_ID'],
        private_key_path: Rails.root.join('config/keys/cf.pem')
      )
    end
  end
end
