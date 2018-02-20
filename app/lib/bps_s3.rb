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

  def link(key)
    "https://#{cf_host}/#{key}"
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
    Aws::S3::Resource.new(
      region: 'us-east-2',
      credentials: Aws::Credentials.new(
        Rails.application.secrets[:s3_access_key],
        Rails.application.secrets[:s3_secret]
      )
    ).bucket(full_bucket)
  end

  def cf_host
    ENV["CLOUDFRONT_#{@endpoint.upcase}_ENDPOINT"]
  end
end
