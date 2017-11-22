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
    get_object(bucket: bucket, key: key).presigned_url(:get, expires_in: 20.minutes).to_s
  end

  def self.download(bucket:, key:)
    get_object(bucket: bucket, key: key).get.body.string
  end

  def self.list(bucket:, prefix: "")
    in_bucket(bucket).objects({prefix: prefix})
  end
end
