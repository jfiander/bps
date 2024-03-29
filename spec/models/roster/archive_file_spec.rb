# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Roster::ArchiveFile do
  let(:archive) { create(:roster_archive_file, file: File.open(test_image(200, 500), 'r')) }

  it 'has the correct table_name' do
    expect(described_class.table_name).to eql('roster_archive_files')
  end

  it 'archives the current roster without errors' do
    expect { described_class.archive! }.not_to raise_error
  end

  it 'returns a valid link' do
    expect(archive.link).to match(
      %r{\Ahttps://files.development.bpsd9.org/uploaded/roster/archive_files/\d+/test_image.jpg\?}
    )
  end
end
