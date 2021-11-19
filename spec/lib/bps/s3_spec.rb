# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BPS::S3, type: :lib do
  describe 'bucket namess' do
    it 'generates the correct static bucket name' do
      expect(described_class.new(:static).full_bucket).to eql('bps-static-files')
    end

    it 'generates the correct files bucket name' do
      expect(described_class.new(:files).full_bucket).to eql('bps-development-files')
    end

    it 'generates the correct bilge bucket name' do
      expect(described_class.new(:bilge).full_bucket).to eql('bps-development-bilge')
    end

    it 'generates the correct photos bucket name' do
      expect(described_class.new(:photos).full_bucket).to eql('bps-development-photos')
    end

    it 'generates the correct float plans bucket name' do
      expect(described_class.new(:floatplans).full_bucket).to eql('bps-development-floatplans')
    end
  end

  describe 'behaviors' do
    before do
      @bps_s3 = described_class.new(:files)
    end

    it 'detects files' do
      expect(@bps_s3.has?('test-key.abc')).to be(true)
    end

    it 'generates a correct link' do
      expect(@bps_s3.link('test-key.abc')).to match(%r{\Ahttps://files.development.bpsd9.org/test-key.abc\?[^ ]*?})
    end

    it 'lists the contents of the bucket' do
      expect(@bps_s3.list).to be_a(Aws::Resources::Collection)
    end

    it 'gets a file from the bucket' do
      expect(@bps_s3.object('something.abc')).to be_a(Aws::S3::Object)
    end

    it 'downloads a file from the bucket' do
      expect(@bps_s3.download('something.abc')).to eql('something goes here')
    end

    it 'uploads a file to the bucket' do
      expect(@bps_s3.upload(file: File.new('tmp/run/something.abc', 'w+'), key: 'something.abc')).to be(true)
    end

    it 'moves a file in the bucket' do
      expect { @bps_s3.move('something.abc', 'new.abc') }.not_to raise_error
    end

    it 'removes a file to the bucket' do
      expect { @bps_s3.remove_object('something.abc') }.not_to raise_error
    end
  end

  describe 'CloudFront subdomains' do
    before do
      @files_bucket = described_class.new(:files)
      @static_bucket = described_class.new(:static)
    end

    context 'when in development' do
      before do
        allow(ENV).to(receive(:[]).with('ASSET_ENVIRONMENT').and_return('development'))
      end

      it 'generates the correct subdomain' do
        expect(@files_bucket.send(:cf_subdomain)).to eql('files.development')
      end

      it 'generates the correct static subdomain' do
        expect(@static_bucket.send(:cf_subdomain)).to eql('static')
      end
    end

    context 'when in staging' do
      before do
        allow(ENV).to(receive(:[]).with('ASSET_ENVIRONMENT').and_return('staging'))
      end

      it 'generates the correct subdomain' do
        expect(@files_bucket.send(:cf_subdomain)).to eql('files.staging')
      end

      it 'generates the correct static subdomain' do
        expect(@static_bucket.send(:cf_subdomain)).to eql('static')
      end
    end

    context 'when in production' do
      before do
        allow(ENV).to(receive(:[]).with('ASSET_ENVIRONMENT').and_return('production'))
      end

      it 'generates the correct subdomain' do
        expect(@files_bucket.send(:cf_subdomain)).to eql('files')
      end

      it 'generates the correct static subdomain' do
        expect(@static_bucket.send(:cf_subdomain)).to eql('static')
      end
    end
  end
end
