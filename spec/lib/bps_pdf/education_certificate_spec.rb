# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BpsPdf::EducationCertificate, type: :lib do
  context 'default user' do
    before(:each) do
      @user = FactoryBot.create(:user, grade: 'N')
    end

    it 'should successfully generate a base certificate PDF' do
      expect { BpsPdf::EducationCertificate.for(@user) }.not_to raise_error
    end

    it 'should work with CVE' do
      FactoryBot.create(:course_completion, user: @user, course_key: 'VSC')
      expect { BpsPdf::EducationCertificate.for(@user) }.not_to raise_error
    end

    it 'should work with ME' do
      FactoryBot.create(:course_completion, user: @user, course_key: 'ME')
      expect { BpsPdf::EducationCertificate.for(@user) }.not_to raise_error
    end

    it 'should work with old ME modules' do
      FactoryBot.create(:course_completion, user: @user, course_key: 'ME101')
      FactoryBot.create(:course_completion, user: @user, course_key: 'ME102')
      FactoryBot.create(:course_completion, user: @user, course_key: 'ME103')
      expect { BpsPdf::EducationCertificate.for(@user) }.not_to raise_error
    end

    it 'should work with a modern ME course' do
      FactoryBot.create(:course_completion, user: @user, course_key: 'NS_000C')
      expect { BpsPdf::EducationCertificate.for(@user) }.not_to raise_error
    end

    describe 'BOC' do
      it 'should work with IN' do
        FactoryBot.create(:course_completion, user: @user, course_key: 'BOC_IN')
        expect { BpsPdf::EducationCertificate.for(@user) }.not_to raise_error
      end

      it 'should work with CN' do
        FactoryBot.create(:course_completion, user: @user, course_key: 'BOC_CN')
        expect { BpsPdf::EducationCertificate.for(@user) }.not_to raise_error
      end

      it 'should work with ACN' do
        FactoryBot.create(:course_completion, user: @user, course_key: 'BOC_ACN')
        expect { BpsPdf::EducationCertificate.for(@user) }.not_to raise_error
      end

      it 'should work with ON' do
        FactoryBot.create(:course_completion, user: @user, course_key: 'BOC_ON')
        expect { BpsPdf::EducationCertificate.for(@user) }.not_to raise_error
      end
    end
  end

  it 'should work with GB Emeritus' do
    user = FactoryBot.create(:user, mm: 50)
    expect { BpsPdf::EducationCertificate.for(user) }.not_to raise_error
  end

  it 'should work with Life Member' do
    user = FactoryBot.create(:user, life: Date.today)
    expect { BpsPdf::EducationCertificate.for(user) }.not_to raise_error
  end

  it 'should work with Senior Member' do
    user = FactoryBot.create(:user, senior: Date.today)
    expect { BpsPdf::EducationCertificate.for(user) }.not_to raise_error
  end

  it 'should work with EdPro' do
    user = FactoryBot.create(:user, ed_pro: Date.today)
    expect { BpsPdf::EducationCertificate.for(user) }.not_to raise_error
  end

  it 'should work with EdAch' do
    user = FactoryBot.create(:user, ed_ach: Date.today)
    expect { BpsPdf::EducationCertificate.for(user) }.not_to raise_error
  end
end
