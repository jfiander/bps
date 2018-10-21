# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Roster::ArchiveFile, type: :model do
  before(:each) do
    @archive = FactoryBot.create(:roster_archive_file, file: File.open(test_image(200, 500), 'r'))
  end

  it 'should have the correct table_name' do
    expect(Roster::ArchiveFile.table_name).to eql('roster_archive_files')
  end

  it 'should archive the current roster without errors' do
    expect { Roster::ArchiveFile.archive! }.not_to raise_error
  end

  it 'should return a valid link' do
    expect(@archive.link).to match(
      %r{\Ahttps://files.development.bpsd9.org/uploaded/roster/archive_files/\d+/test_image.jpg\?}
    )
  end
end
