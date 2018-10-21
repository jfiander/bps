# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BpsS3, type: :lib do
  describe 'bucket namess' do
    it 'should generate the correct static bucket name' do
      expect(BpsS3.new(:static).full_bucket).to eql('bps-static-files')
    end

    it 'should generate the correct files bucket name' do
      expect(BpsS3.new(:files).full_bucket).to eql('bps-development-files')
    end

    it 'should generate the correct bilge bucket name' do
      expect(BpsS3.new(:bilge).full_bucket).to eql('bps-development-bilge')
    end

    it 'should generate the correct photos bucket name' do
      expect(BpsS3.new(:photos).full_bucket).to eql('bps-development-photos')
    end

    it 'should generate the correct float plans bucket name' do
      expect(BpsS3.new(:floatplans).full_bucket).to eql('bps-development-floatplans')
    end
  end

  describe 'behaviors' do
    before(:each) do
      @bps_s3 = BpsS3.new(:files)
    end

    it 'should detect files' do
      expect(@bps_s3.has?('test-key.abc')).to be(true)
    end

    it 'should generate a correct link' do
      expect(@bps_s3.link('test-key.abc')).to match(%r{\Ahttps://files.development.bpsd9.org/test-key.abc\?[^ ]*?})
    end

    it 'should list the contents of the bucket' do
      expect(@bps_s3.list).to be_a(Aws::Resources::Collection)
    end

    it 'should get a file from the bucket' do
      expect(@bps_s3.object('something.abc')).to be_a(Aws::S3::Object)
    end

    it 'should download a file from the bucket' do
      expect(@bps_s3.download('something.abc')).to eql('something goes here')
    end

    it 'should upload a file to the bucket' do
      expect(@bps_s3.upload(file: File.new('tmp/run/something.abc', 'w+'), key: 'something.abc')).to be(true)
    end

    it 'should move a file in the bucket' do
      expect { @bps_s3.move('something.abc', 'new.abc') }.not_to raise_error
    end

    it 'should remove a file to the bucket' do
      expect { @bps_s3.remove_object('something.abc') }.not_to raise_error
    end
  end

  describe 'CloudFront subdomains' do
    before(:each) do
      @files_bucket = BpsS3.new(:files)
      @static_bucket = BpsS3.new(:static)
    end

    context 'development' do
      before(:each) do
        allow(ENV).to(receive(:[]).with('ASSET_ENVIRONMENT').and_return('development'))
      end

      it 'should generate the correct subdomain' do
        expect(@files_bucket.send(:cf_subdomain)).to eql('files.development')
      end

      it 'should generate the correct static subdomain' do
        expect(@static_bucket.send(:cf_subdomain)).to eql('static')
      end
    end

    context 'staging' do
      before(:each) do
        allow(ENV).to(receive(:[]).with('ASSET_ENVIRONMENT').and_return('staging'))
      end

      it 'should generate the correct subdomain' do
        expect(@files_bucket.send(:cf_subdomain)).to eql('files.staging')
      end

      it 'should generate the correct static subdomain' do
        expect(@static_bucket.send(:cf_subdomain)).to eql('static')
      end
    end

    context 'production' do
      before(:each) do
        allow(ENV).to(receive(:[]).with('ASSET_ENVIRONMENT').and_return('production'))
      end

      it 'should generate the correct subdomain' do
        expect(@files_bucket.send(:cf_subdomain)).to eql('files')
      end

      it 'should generate the correct static subdomain' do
        expect(@static_bucket.send(:cf_subdomain)).to eql('static')
      end
    end
  end
end
