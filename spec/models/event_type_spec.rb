require 'rails_helper'

RSpec.describe EventType, type: :model do
  describe 'form selectors' do
    it 'should generate the correct form select field data' do
      abc = FactoryBot.create(:event_type)
      FactoryBot.create(:event_type, title: 'Emergencies on Board', event_category: 'seminar')
      n = FactoryBot.create(:event_type, title: 'Navigation', event_category: 'advanced_grade')
      jn = FactoryBot.create(:event_type, title: 'Junior Navigation', event_category: 'advanced_grade')
      sail = FactoryBot.create(:event_type, title: 'Sail', event_category: 'elective')

      select_data = EventType.selector(:course)

      expect(select_data).to eql(
        [
          ['Public Course Courses', ''],
          ['-----------------------', ''],
          ["America's Boating Course", abc.id],
          ['', ''],
          ['Advanced Grade Courses', ''],
          ['------------------------', ''],
          ['Navigation', n.id],
          ['Junior Navigation', jn.id],
          ['', ''],
          ['Elective Courses', ''],
          ['------------------', ''],
          ['Sail', sail.id]
        ]
      )
    end
  end
end
