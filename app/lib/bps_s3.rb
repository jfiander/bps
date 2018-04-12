# Helper for accessing environmented S3 buckets and CloudFront links
class BpsS3
  # usage:  BpsS3.new { |b| b.bucket = :files }

  attr_accessor :bucket
  # bilge, files, photos

  def initialize
    @environment = ENV['ASSET_ENVIRONMENT']
    yield self if block_given?

    if @bucket == :static
      @endpoint = @environment = :static
      @bucket = :files
    else
      @endpoint = @bucket
    end
  end

  def link(key, signed: false)
    signed ? signed_link(key) : cf_link(key)
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

  def signed_link(key)
    url = cf_link(key)
    time = Time.now + 3600
    cf_signer.signed_url(
      url,
      expires: time
    )
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
end
