# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BPS::PDF::EducationCertificate, slow: true, type: :lib do
  let(:user) { FactoryBot.create(:user, grade: 'N') }

  context 'with a default user' do
    it 'successfully generates a base certificate PDF' do
      expect { described_class.for(user) }.not_to raise_error
    end

    it 'works with CVE' do
      FactoryBot.create(:course_completion, user: user, course_key: 'VSC')
      expect { described_class.for(user) }.not_to raise_error
    end

    it 'works with ME' do
      FactoryBot.create(:course_completion, user: user, course_key: 'ME')
      expect { described_class.for(user) }.not_to raise_error
    end

    it 'works with BH' do
      FactoryBot.create(:course_completion, user: user, course_key: 'BH')
      expect { described_class.for(user) }.not_to raise_error
    end

    it 'works with old ME modules' do
      FactoryBot.create(:course_completion, user: user, course_key: 'ME101')
      FactoryBot.create(:course_completion, user: user, course_key: 'ME102')
      FactoryBot.create(:course_completion, user: user, course_key: 'ME103')
      expect { described_class.for(user) }.not_to raise_error
    end

    it 'works with a modern ME course' do
      FactoryBot.create(:course_completion, user: user, course_key: 'NS_000C')
      expect { described_class.for(user) }.not_to raise_error
    end

    describe 'BOC' do
      it 'works with IN' do
        FactoryBot.create(:course_completion, user: user, course_key: 'BOC_IN')
        expect { described_class.for(user) }.not_to raise_error
      end

      it 'works with CN' do
        FactoryBot.create(:course_completion, user: user, course_key: 'BOC_CN')
        expect { described_class.for(user) }.not_to raise_error
      end

      it 'works with ACN' do
        FactoryBot.create(:course_completion, user: user, course_key: 'BOC_ACN')
        expect { described_class.for(user) }.not_to raise_error
      end

      it 'works with ON' do
        FactoryBot.create(:course_completion, user: user, course_key: 'BOC_ON')
        expect { described_class.for(user) }.not_to raise_error
      end
    end
  end

  it 'works with GB Emeritus' do
    user = FactoryBot.create(:user, mm: 50)
    expect { described_class.for(user) }.not_to raise_error
  end

  it 'works with Life Member' do
    user = FactoryBot.create(:user, life: Time.zone.today)
    expect { described_class.for(user) }.not_to raise_error
  end

  it 'works with Senior Member' do
    user = FactoryBot.create(:user, senior: Time.zone.today)
    expect { described_class.for(user) }.not_to raise_error
  end

  it 'works with EdPro' do
    user = FactoryBot.create(:user, ed_pro: Time.zone.today)
    expect { described_class.for(user) }.not_to raise_error
  end

  it 'works with EdAch' do
    user = FactoryBot.create(:user, ed_ach: Time.zone.today)
    expect { described_class.for(user) }.not_to raise_error
  end
end
