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

  def self.download(bucket:, key:)
    in_bucket(bucket).objects({prefix: key}).first.get.body.string
  end
end
