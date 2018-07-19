# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventType, type: :model do
  it 'should generate a valid searchable array' do
    FactoryBot.create(:event_type, event_category: 'public', title: 'ABC')
    FactoryBot.create(:event_type, event_category: 'seminar', title: '123')

    expect(EventType.searchable).to eql([%w[public abc], %w[seminar 123]])
  end

  describe 'form selectors' do
    it 'should generate the correct form select field data' do
      abc = FactoryBot.create(:event_type)
      FactoryBot.create(:event_type, title: 'Emergencies on Board', event_category: 'seminar')
      n = FactoryBot.create(:event_type, title: 'Navigation', event_category: 'advanced_grade')
      jn = FactoryBot.create(:event_type, title: 'Junior Navigation', event_category: 'advanced_grade')
      sail = FactoryBot.create(:event_type, title: 'Sail', event_category: 'elective')

      select_data = EventType.selector('course')

      expect(select_data).to eql(
        [
          ['Public Course Courses', ''],
          ['-----------------------', ''],
          ["America's Boating Course", abc.id],
          ['', ''],
          ['Advanced Grade Courses', ''],
          ['------------------------', ''],
          ['Junior Navigation', jn.id],
          ['Navigation', n.id],
          ['', ''],
          ['Elective Courses', ''],
          ['------------------', ''],
          ['Sail', sail.id]
        ]
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
end
