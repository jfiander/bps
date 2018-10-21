# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportUsers, type: :service do
  let(:import) { File.open(File.join(Rails.root, 'spec', 'import.csv'), 'r+') }

  before(:each) do
    FileUtils.cp(File.join(Rails.root, 'spec', 'demo_import.csv'), File.join(Rails.root, 'spec', 'import.csv'))
  end

  describe 'user handling' do
    before(:each) do
      @update = FactoryBot.create(:user, certificate: 'E012345', email: 'updated.person@example.com')
      @remove = FactoryBot.create(:user, certificate: 'E001234')
    end

    describe 'creating' do
      it 'should correctly add new users' do
        expect(User.find_by(certificate: 'E123456')).to be_blank

        ImportUsers::Import.new(import).call
        user = User.find_by(certificate: 'E123456')
        expect(user).to be_present
        expect(user.locked?).to be(false)
      end

      it 'should detect duplicate email addresses' do
        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E567890').email).to match(/duplicate-.*?@bpsd9.org/)
      end

      it 'should handle missing email addresses' do
        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E135792').email).to match(/nobody-.*?@bpsd9.org/)
      end
    end

    describe 'updating' do
      it 'should not remove the user' do
        expect(User.find_by(certificate: 'E012345')).to be_present

        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E012345')).to be_present
      end

      it 'should not lock the user' do
        expect(User.find_by(certificate: 'E012345').locked?).to be(false)

        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E012345').locked?).to be(false)
      end

      it 'should not update the email address' do
        expect(User.find_by(certificate: 'E012345').email).to eql('updated.person@example.com')

        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E012345').email).to eql('updated.person@example.com')
      end

      it 'should update the rank' do
        expect(User.find_by(certificate: 'E012345').rank).to be_nil

        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E012345').rank).to be_present
      end

      it 'should add course completions' do
        expect(User.find_by(certificate: 'E012345').course_completions).to be_blank

        ImportUsers::Import.new(import).call
        expect(User.find_by(certificate: 'E012345').course_completions).to be_present
      end
    end

    it 'should correctly lock users' do
      user = User.find_by(certificate: 'E001234')
      expect(user).to be_present
      expect(user.locked?).to be(false)

      ImportUsers::Import.new(import, lock: true).call
      user = User.find_by(certificate: 'E001234')
      expect(user).to be_present
      expect(user.locked?).to be(true)
    end

    it 'should correctly not lock users' do
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
    before(:each) do
      ImportUsers::Import.new(import).call
    end

    it 'should use SQ_Rank over HQ_Rank' do
      expect(User.find_by(certificate: 'E123456').rank).to eql('P/C')
    end

    it 'should use Rank over SQ_Rank and HQ_Rank' do
      expect(User.find_by(certificate: 'E012345').rank).to eql('P/Lt/C')
    end
  end
end
