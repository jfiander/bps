# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportUsers, type: :service do
  let(:import) { Rails.root.join('spec', 'import.csv').open('r+') }

  before do
    FileUtils.cp(Rails.root.join('spec', 'demo_import.csv'), Rails.root.join('spec', 'import.csv'))
  end

  describe 'user handling' do
    before do
      @update = create(:user, certificate: 'E012345', email: 'updated.person@example.com')
      @remove = create(:user, certificate: 'E001234')
    end

    describe 'creating' do
      it 'correctly adds new users' do
        expect(User.find_by(certificate: 'E123456')).to be_blank

        ImportUsers::Import.new(import).call
        user = User.find_by(certificate: 'E123456')
        expect(user).to be_present
        expect(user.locked?).to be(false)
      end

      it 'detects duplicate email addresses' do
        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E567890').email).to match(/duplicate-.*?@bpsd9.org/)
      end

      it 'handles missing email addresses' do
        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E135792').email).to match(/nobody-.*?@bpsd9.org/)
      end
    end

    describe 'updating' do
      it 'does not remove the user' do
        expect(User.find_by(certificate: 'E012345')).to be_present

        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E012345')).to be_present
      end

      it 'does not lock the user' do
        expect(User.find_by(certificate: 'E012345').locked?).to be(false)

        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E012345').locked?).to be(false)
      end

      it 'does not update the email address' do
        expect(User.find_by(certificate: 'E012345').email).to eql('updated.person@example.com')

        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E012345').email).to eql('updated.person@example.com')
      end

      it 'updates the rank' do
        expect(User.find_by(certificate: 'E012345').rank).to be_nil

        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E012345').rank).to be_present
      end

      it 'adds course completions' do
        expect(User.find_by(certificate: 'E012345').course_completions).to be_blank

        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E012345').course_completions).to be_present
      end
    end

    it 'correctly locks users' do
      user = User.find_by(certificate: 'E001234')
      expect(user).to be_present
      expect(user.locked?).to be(false)

      ImportUsers::Import.new(import, lock: true).call
      user = User.find_by(certificate: 'E001234')
      expect(user).to be_present
      expect(user.locked?).to be(true)
    end

    it 'correctly does not lock users' do
      user = User.find_by(certificate: 'E001234')
      expect(user).to be_present
      expect(user.locked?).to be(false)

      ImportUsers::Import.new(import, lock: false).call
      user = User.find_by(certificate: 'E001234')
      expect(user).to be_present
      expect(user.locked?).to be(false)
    end
  end

  describe 'ranks' do
    before do
      ImportUsers::Import.new(import).call
    end

    it 'uses SQ_Rank over HQ_Rank' do
      expect(User.find_by(certificate: 'E123456').rank).to eql('P/C')
    end

    it 'uses Rank over SQ_Rank and HQ_Rank' do
      expect(User.find_by(certificate: 'E012345').rank).to eql('P/Lt/C')
    end
  end
end
