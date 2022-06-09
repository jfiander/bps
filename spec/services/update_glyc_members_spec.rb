# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateGLYCMembers, type: :service do
  let(:pdf) { file_fixture('update_glyc_members/GLYC_Roster.pdf') }
  let(:service) { described_class.new(pdf) }

  it 'updates the stored members' do
    create(:glyc_member)

    service.update

    expect(GLYCMember.all).to contain_exactly(
      having_attributes(email: 'member1@example.com'),
      having_attributes(email: 'member2@example.com')
    )
  end
end
