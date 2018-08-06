# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventType, type: :model do
  it 'should generate a valid searchable array' do
    FactoryBot.create(:event_type, event_category: 'public', title: 'ABC')
    FactoryBot.create(:event_type, event_category: 'seminar', title: '123')

    expect(EventType.searchable).to eql([%w[public abc], %w[seminar 123]])
  end

  describe 'form selectors' do
    before(:each) do
      @abc = FactoryBot.create(:event_type, title: "America's Boating Course")
      @eob = FactoryBot.create(:event_type, title: 'Emergencies on Board', event_category: 'seminar')
      @n = FactoryBot.create(:event_type, title: 'Navigation', event_category: 'advanced_grade')
      @jn = FactoryBot.create(:event_type, title: 'Junior Navigation', event_category: 'advanced_grade')
      @sail = FactoryBot.create(:event_type, title: 'Sail', event_category: 'elective')
    end

    it 'should generate the correct course select field data' do
      allow(ENV).to receive(:[]).with('USE_NEW_AG_TITLES').and_return('disabled')
      select_data = EventType.selector('course')

      expect(select_data).to eql(
        'Public' => [["America's Boating Course", @abc.id]],
        'Advanced Grade' => [
          ['Junior Navigation', @jn.id],
          ['Navigation', @n.id]
        ],
        'Elective' => [['Sail', @sail.id]]
      )
    end

    it 'should generate the correct seminar select field data' do
      allow(ENV).to receive(:[]).with('USE_NEW_AG_TITLES').and_return('disabled')
      select_data = EventType.selector('seminar')

      expect(select_data).to eql(
        [['Emergencies on Board', @eob.id]]
      )
    end
  end

  describe 'ordering' do
    before(:each) do
      FactoryBot.create(:event_type, event_category: :seminar, title: 'paddle')
      FactoryBot.create(:event_type, event_category: :elective, title: 'sail')
      FactoryBot.create(:event_type, event_category: :meeting, title: 'member')
      FactoryBot.create(:event_type, event_category: :public)
      FactoryBot.create(
        :event_type,
        event_category: :advanced_grade,
        title: 'advanced_piloting'
      )
      @event_types = EventType.all
    end

    it 'should correctly order event_types by name' do
      expect(
        @event_types.map(&:order_position)
      ).to eql(
        [8, 7, 9, 1, 4]
      )
    end
  end

  describe 'new titles' do
    before(:each) do
      @event_type = FactoryBot.create(
        :event_type,
        event_category: 'advanced_grade',
        title: 'Junior Navigation'
      )
    end

    it 'should use the correct old title' do
      allow(ENV).to receive(:[]).with('USE_NEW_AG_TITLES').and_return('disabled')
      expect(@event_type.display_title).to eql('Junior Navigation')
    end

    it 'should use the correct new title' do
      allow(ENV).to receive(:[]).with('USE_NEW_AG_TITLES').and_return('enabled')
      expect(@event_type.display_title).to eql('Offshore Navigation')
    end
  end
end
