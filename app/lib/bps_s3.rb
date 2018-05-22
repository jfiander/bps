# Helper for accessing environmented S3 buckets and CloudFront links
class BpsS3
  # usage:  BpsS3.new { |b| b.bucket = :files }

  attr_accessor :bucket
  # bilge, files, photos

  def initialize(bucket = nil)
    @environment = ENV['ASSET_ENVIRONMENT']
    @bucket = bucket
    yield self if block_given?
    prepare_bucket

    @force_signed = @bucket.in?(%i[seo files bilge]) && @environment != :static
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

  def download(key)
    object(key).get.body.read
  end

  def upload(file:, key:)
    object(key).upload_file(file.path)
  end

  def remove_object(key)
    object(key).delete
  end

  def full_bucket
    return 'bps-seo' if @bucket == :seo

    "bps-#{@environment}-#{@bucket}"
  end

  private

  def s3
    @s3 ||= Aws::S3::Resource.new(
      region: 'us-east-2',
      credentials: Aws::Credentials.new(
        Rails.application.secrets[:s3_access_key],
        Rails.application.secrets[:s3_secret]
      )
    ).bucket(full_bucket)
  end

  def cf_link(key)
    "https://#{cf_host}/#{key}"
  end

  def prepare_bucket
    case @bucket
    when :static
      @endpoint = @environment = :static
      @bucket = :files
    when :seo
      @endpoint = @environment = :seo
      @bucket = :seo
    else
      @endpoint = @bucket
    end
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

  def cf_host
    ENV["CLOUDFRONT_#{@endpoint.upcase}_ENDPOINT"]
  end

  def sign?(signed)
    return false if Rails.env.test?
    return true if @force_signed
    signed
  end
end
