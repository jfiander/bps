# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarHelper, type: :helper do
  it 'should generate a correctly formatted calendar URL' do
    expect(render_calendar('12345:FFFFFF/67890:ABCDEF')).to eql(
      'https://calendar.google.com/calendar/b/2/embed?showTitle=0&showPrint=0' \
      '&height=600&wkst=1&bgcolor=%23FFFFFF&ctz=America%2FNew_York' \
      '&src=bpsd9.org_12345%40group.calendar.google.com&color=%23FFFFFF' \
      '&src=bpsd9.org_67890%40group.calendar.google.com&color=%23ABCDEF'
    )
  end
end
