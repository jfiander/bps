# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventType, type: :model do
  it 'generates a valid searchable array' do
    FactoryBot.create(:event_type, event_category: 'public', title: 'ABC')
    FactoryBot.create(:event_type, event_category: 'seminar', title: '123')

    expect(described_class.searchable).to eql([%w[public abc], %w[seminar 123]])
  end

  describe 'form selectors' do
    before do
      @abc = FactoryBot.create(:event_type, title: "America's Boating Course")
      @eob = FactoryBot.create(:event_type, title: 'Emergencies Onboard', event_category: 'seminar')
      @n = FactoryBot.create(:event_type, title: 'Navigation', event_category: 'advanced_grade')
      @jn = FactoryBot.create(:event_type, title: 'Junior Navigation', event_category: 'advanced_grade')
      @sail = FactoryBot.create(:event_type, title: 'Sail', event_category: 'elective')
    end

    it 'generates the correct course select field data' do
      allow(ENV).to receive(:[]).with('USE_NEW_AG_TITLES').and_return('disabled')
      select_data = described_class.selector('course')

      expect(select_data).to eql(
        'Public' => [["America's Boating Course", @abc.id]],
        'Advanced Grade' => [['Junior Navigation', @jn.id], ['Navigation', @n.id]],
        'Elective' => [['Sail', @sail.id]]
      )
    end

    it 'generates the correct seminar select field data' do
      allow(ENV).to receive(:[]).with('USE_NEW_AG_TITLES').and_return('disabled')
      select_data = described_class.selector('seminar')

      expect(select_data).to eql([['Emergencies Onboard', @eob.id]])
    end
  end

  describe 'ordering' do
    before do
      FactoryBot.create(:event_type, event_category: :seminar, title: 'paddle')
      FactoryBot.create(:event_type, event_category: :elective, title: 'sail')
      FactoryBot.create(:event_type, event_category: :meeting, title: 'member')
      FactoryBot.create(:event_type, event_category: :public)
      FactoryBot.create(:event_type, event_category: :advanced_grade, title: 'advanced_piloting')
      @event_types = described_class.all
    end

    it 'correctlies order event_types by name' do
      expect(@event_types.map(&:order_position)).to eql(%w[8 7 9 1 4a])
    end
  end
end
