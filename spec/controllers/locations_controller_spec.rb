# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationsController do
  let(:user) { create(:user) }

  before do
    admin = create(:role, name: 'admin')
    create(:role, name: 'course', parent: admin)
    user.permit!(:course)
    sign_in(user)
  end

  describe 'PATCH #update' do
    let(:location) { create(:location) }

    it 'attaches an uploaded picture' do
      picture = Rack::Test::UploadedFile.new(test_image(500, 500), 'image/jpeg')

      patch(:update, params: { id: location.id, location: { picture: } })

      expect(location.reload.picture).to be_present
    end

    it 'removes the picture when requested' do
      location.update!(picture: File.open(test_image(500, 500), 'r'))

      patch(:update, params: { id: location.id, location: { delete_attachment: '1' } })

      expect(location.reload.picture).not_to be_present
    end
  end
end
