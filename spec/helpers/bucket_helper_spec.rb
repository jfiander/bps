# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BucketHelper, type: :helper do
  before do
    @static = described_class.static_bucket
    @files = described_class.files_bucket
    @bilge = described_class.bilge_bucket
    @photos = described_class.photos_bucket
  end

  it 'returns the correct static bucket' do
    expect(@static).to be_a(BpsS3)
    expect(@static.bucket).to be(:files)
  end

  it 'returns the correct files bucket' do
    expect(@files).to be_a(BpsS3)
    expect(@files.bucket).to be(:files)
  end

  it 'returns the correct bilge bucket' do
    expect(@bilge).to be_a(BpsS3)
    expect(@bilge.bucket).to be(:bilge)
  end

  it 'returns the correct photos bucket' do
    expect(@photos).to be_a(BpsS3)
    expect(@photos.bucket).to be(:photos)
  end
end
