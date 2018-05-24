# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BucketHelper, type: :helper do
  before(:each) do
    @static = BucketHelper.static_bucket
    @files = BucketHelper.files_bucket
    @bilge = BucketHelper.bilge_bucket
    @photos = BucketHelper.photos_bucket
  end

  it 'should return the correct static bucket' do
    expect(@static).to be_a(BpsS3)
    expect(@static.bucket).to eql(:files)
  end

  it 'should return the correct static bucket' do
    expect(@files).to be_a(BpsS3)
    expect(@files.bucket).to eql(:files)
  end

  it 'should return the correct static bucket' do
    expect(@bilge).to be_a(BpsS3)
    expect(@bilge.bucket).to eql(:bilge)
  end

  it 'should return the correct static bucket' do
    expect(@photos).to be_a(BpsS3)
    expect(@photos.bucket).to eql(:photos)
  end
end
