require 'rails_helper'

RSpec.describe BpsS3, type: :lib do
  before(:each) do
    @bps_s3 = BpsS3.new { |b| b.bucket = :files }
  end

  describe 'bucket namess' do
    it 'should generate the correct static bucket name' do
      expect(BpsS3.new { |b| b.bucket = :static }.full_bucket).to eql(
        'bps-static-files'
      )
    end

    it 'should generate the correct files bucket name' do
      expect(BpsS3.new { |b| b.bucket = :files }.full_bucket).to eql(
        'bps-development-files'
      )
    end

    it 'should generate the correct bilge bucket name' do
      expect(BpsS3.new { |b| b.bucket = :bilge }.full_bucket).to eql(
        'bps-development-bilge'
      )
    end

    it 'should generate the correct photos bucket name' do
      expect(BpsS3.new { |b| b.bucket = :photos }.full_bucket).to eql(
        'bps-development-photos'
      )
    end
  end

  it 'should generate a correct link' do
    expect(@bps_s3.link('test-key.abc')).to eql(
      'https://files.development.bpsd9.org/test-key.abc'
    )
  end

  it 'should list the contents of the bucket' do
    expect(@bps_s3.list).to be_a(Aws::Resources::Collection)
  end

  it 'should get a file from the bucket' do
    expect(@bps_s3.object('something.abc')).to be_a(Aws::S3::Object)
  end

  it 'should download the first file from the bucket' do
    expect(@bps_s3.download('something.abc')).to eql(
      'something goes here'
    )
  end

  it 'should upload a file to the bucket' do
    expect(
      @bps_s3.upload(
        file: File.new('tmp/something.abc', 'w+'),
        key: 'something.abc'
      )
    ).to be(true)
  end
end
