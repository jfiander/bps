module BpsS3
  def self.in_bucket(bucket_type)
    # Buckets:
    #  bps-bilge
    #  bps-files
    #  bps-photos
    Aws::S3::Resource.new(
      region: 'us-east-2',
      credentials: Aws::Credentials.new(Rails.application.secrets[:s3_access_key], Rails.application.secrets[:s3_secret])
    ).bucket("bps-#{bucket_type.to_s}")
  end

  def self.upload(file, bucket:, key:)
    in_bucket(bucket).object(key).upload_file(file.path) #, acl: 'public-read'
  end

  def self.get_object(bucket:, key:)
    in_bucket(bucket).object(key)
  end

  def self.link(bucket:, key:)
    object = get_object(bucket: bucket, key: key)
    if object.exists?
      object.presigned_url(
        :get,
        expires_in: 20.minutes,
        response_content_disposition: "attachment;filename=Bilge_Chatter_#{key.gsub('/', '-')}"
      ).to_s
    end
  end

  def self.download(bucket:, key:)
    get_object(bucket: bucket, key: key).get.body.string
  end

  def self.download_with_prefix(bucket:, prefix:, to:)
    in_bucket(bucket).objects({prefix: prefix}).each do |obj|
      outfile = "#{to}/#{obj.key}".sub(prefix, '')
      next if File.directory?(outfile)
      outdir = outfile.dup.split("/")
      outdir.pop
      FileUtils.mkdir_p(outdir.join("/"))
      obj.get(response_target: outfile)
    end
  end

  def self.list(bucket:, prefix: "")
    in_bucket(bucket).objects({prefix: prefix})
  end

  def self.remove_object(bucket:, key:)
    in_bucket(bucket).object(key).delete
  end

  module CloudFront
    def self.host
      ENV['CLOUDFRONT_ENDPOINT']
    end

    def self.link(key)
      "https://#{host}/#{key}"
    end
  end
end
