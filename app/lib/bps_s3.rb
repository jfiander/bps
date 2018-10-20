# frozen_string_literal: true

# Helper for accessing environmented S3 buckets and CloudFront links
class BpsS3
  attr_reader :bucket

  def initialize(bucket = nil)
    @environment = ENV['ASSET_ENVIRONMENT'].to_sym
    @bucket = bucket.to_sym
    prepare_bucket
  end

  def link(key, signed: false, time: nil)
    sign?(signed) ? signed_link(key, time) : cf_link(key)
  end

  def list(prefix = '')
    s3.objects(prefix: prefix)
  end

  def object(key)
    s3.object(key)
  end

  def has?(key)
    s3.object(key)&.exists?
  end

  def download(key)
    object(key).get.body.read
  end

  def upload(file:, key:)
    object(key).upload_file(file.path)
  end

  def move(key, new_key)
    object(key).move_to("#{full_bucket}/#{new_key}")
  end

  def remove_object(key)
    object(key).delete
  end

  def full_bucket
    @full_bucket ||= ['bps', @environment, @bucket].compact.join('-')
  end

private

  def valid_buckets
    %i[files photos bilge static seo floatplans]
  end

  def s3
    @s3 ||= Aws::S3::Resource.new(
      region: 'us-east-2',
      credentials: Aws::Credentials.new(
        Rails.application.secrets[:s3_access_key],
        Rails.application.secrets[:s3_secret]
      )
    ).bucket(full_bucket)
  end

  def prepare_bucket
    raise 'Invalid bucket.' unless @bucket.in?(valid_buckets)

    @endpoint = @bucket

    @environment = nil if @bucket == :seo

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

  def sign?(signed = false)
    return true if @bucket.in?(%i[seo files bilge]) && @environment != :static
    signed
  end

  def signed_link(key, time = nil)
    time ||= Time.now + 1.hour
    cf_signer.signed_url(cf_link(key), expires: time)
  end

  def cf_signer
    @cf_signer ||= Aws::CloudFront::UrlSigner.new(
      key_pair_id: Rails.application.secrets[:cf_keypair_id],
    private_key_path: Rails.application.secrets[:cf_private_key_path]
    )
  end
end
