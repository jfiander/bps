# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlagsHelper do
  it 'generates the correct officer flag HTML' do
    expect(officer_flags('PSTFC')).to eql(
      '<div class="officer-flags"><img width="150" height="100" ' \
      'src="https://static.bpsd9.org/flags/PNG/PSTFC.thumb.png" /><br>' \
      '<a disposition="inline" href="https://static.bpsd9.org/flags/PNG/PSTFC.png">PNG</a>' \
      '<span> | </span><a disposition="inline" ' \
      'href="https://static.bpsd9.org/flags/SVG/PSTFC.svg">SVG</a></div>'
    )
  end

  it 'generates the correct single officer insignia HTML' do
    expect(officer_insignia('LT')).to eql(
      '<div class="officer-insignia"><img height="75" ' \
      'src="https://static.bpsd9.org/flags/PNG/insignia/LT.thumb.png" /><br>' \
      '<a disposition="inline" href="https://static.bpsd9.org/flags/PNG/insignia/LT.png">PNG</a>' \
      '<span> | </span>' \
      '<a disposition="inline" href="https://static.bpsd9.org/flags/SVG/insignia/LT.svg">SVG</a>' \
      '</div>'
    )
  end

  it 'generates the correct multiple officer insignia HTML' do
    expect(officer_insignia('DLTC')).to eql(
      '<div class="officer-insignia"><img height="75" ' \
      'src="https://static.bpsd9.org/flags/PNG/insignia/DLTC.thumb.png" /><br>PNG: ' \
      '<a disposition="inline" title="Red" class="red" ' \
      'href="https://static.bpsd9.org/flags/PNG/insignia/DLTC.png">R</a> ' \
      '<a disposition="inline" title="Gold" class="gold" ' \
      'href="https://static.bpsd9.org/flags/PNG/insignia/gold/DLTC.png">G</a> ' \
      '<a disposition="inline" title="Silver" class="silver" ' \
      'href="https://static.bpsd9.org/flags/PNG/insignia/silver/DLTC.png">S</a>' \
      '<span> | </span>SVG: ' \
      '<a disposition="inline" title="Red" class="red" ' \
      'href="https://static.bpsd9.org/flags/SVG/insignia/DLTC.svg">R</a> ' \
      '<a disposition="inline" title="Gold" class="gold" ' \
      'href="https://static.bpsd9.org/flags/SVG/insignia/gold/DLTC.svg">G</a> ' \
      '<a disposition="inline" title="Silver" class="silver" ' \
      'href="https://static.bpsd9.org/flags/SVG/insignia/silver/DLTC.svg">S</a></div>'
    )
  end

  it 'generates the correct pennant HTML' do
    expect(pennant('OIC')).to eql(
      '<div class="officer-flags"><img width="150" height="25" ' \
      'src="https://static.bpsd9.org/flags/PNG/OIC.thumb.png" /><br>' \
      '<a disposition="inline" href="https://static.bpsd9.org/flags/PNG/OIC.png">PNG</a>' \
      '<span> | </span><a disposition="inline" ' \
      'href="https://static.bpsd9.org/flags/SVG/OIC.svg">SVG</a></div>'
    )
  end

  it 'generates the correct grade insignia HTML' do
    expect(grade_insignia(:jn, 40)).to eql(
      '<div class="grade-insignia"><img height="40" ' \
      'src="https://static.bpsd9.org/insignia/PNG/grades/tr/jn.png" /><br>' \
      '<span>PNG: </span><a disposition="inline" title="Transparent background" ' \
      'href="https://static.bpsd9.org/insignia/PNG/grades/tr/jn.png">T</a>' \
      '<span> </span><a disposition="inline" title="Black backgeround" ' \
      'href="https://static.bpsd9.org/insignia/PNG/grades/black/jn.png">B</a>' \
      '<span> </span><a disposition="inline" title="White background" ' \
      'href="https://static.bpsd9.org/insignia/PNG/grades/white/jn.png">W</a>' \
      '<span> | </span><a disposition="inline" ' \
      'href="https://static.bpsd9.org/insignia/SVG/grades/jn.svg">SVG</a></div>'
    )
  end

  it 'generates the correct membership insignia HTML' do
    expect(membership_insignia(:life)).to eql(
      '<div class="membership-insignia"><img width="250" ' \
      'src="https://static.bpsd9.org/insignia/PNG/membership/tr/life.png" /><br>' \
      '<span>PNG: </span><a disposition="inline" title="Transparent background" ' \
      'href="https://static.bpsd9.org/insignia/PNG/membership/tr/life.png">T</a>' \
      '<span> </span><a disposition="inline" title="Black backgeround" ' \
      'href="https://static.bpsd9.org/insignia/PNG/membership/black/life.png">B</a>' \
      '<span> </span><a disposition="inline" title="White background" ' \
      'href="https://static.bpsd9.org/insignia/PNG/membership/white/life.png">W</a>' \
      '<span> | </span><a disposition="inline" ' \
      'href="https://static.bpsd9.org/insignia/SVG/membership/life.svg">SVG</a></div>'
    )
  end

  it 'generates the correct MM insignia HTML' do
    expect(mm_insignia).to eql(
      '<div class="mm-insignia"><img height="30" ' \
      'src="https://static.bpsd9.org/insignia/PNG/mm.png" /><br>' \
      '<a disposition="inline" href="https://static.bpsd9.org/insignia/PNG/mm.png">PNG</a>' \
      '<span> | </span><a disposition="inline" ' \
      'href="https://static.bpsd9.org/insignia/SVG/mm.svg">SVG</a></div>'
    )
  end

  it 'generates the correct GB insignia HTML' do
    expect(gb_insignia).to eql(
      '<div class="gb-insignia"><img height="45" ' \
      'src="https://static.bpsd9.org/insignia/PNG/membership/tr/gb.png" /><br>' \
      '<a disposition="inline" ' \
      'href="https://static.bpsd9.org/insignia/PNG/membership/tr/gb.png">PNG</a>' \
      '</div>'
    )
  end

  it 'generates the correct GB Emeritus insignia HTML' do
    expect(gb_emeritus_insignia).to eql(
      '<div class="gb-emeritus-insignia"><img height="45" ' \
      'src="https://static.bpsd9.org/insignia/PNG/membership/tr/gb_emeritus.png" /><br>' \
      '<a disposition="inline" ' \
      'href="https://static.bpsd9.org/insignia/PNG/membership/tr/gb_emeritus.png">PNG</a>' \
      '</div>'
    )
  end

  describe 'membership_pin' do
    it 'generates the correct Member pin' do
      expect(membership_pin(24, 24)).to eql(
        '<img width="50" ' \
        'src="https://static.bpsd9.org/insignia/PNG/pins/Member.png" />'
      )
    end

    it 'generates the correct 25-Year Member pin' do
      expect(membership_pin(24, 25)).to eql(
        '<img width="50" ' \
        'src="https://static.bpsd9.org/insignia/PNG/pins/25-Year_Member.png" />'
      )
    end

    it 'generates the correct 50-Year Member pin' do
      expect(membership_pin(24, 50)).to eql(
        '<img width="50" ' \
        'src="https://static.bpsd9.org/insignia/PNG/pins/50-Year_Member.png" />'
      )
    end

    it 'generates the correct Life Member pin' do
      expect(membership_pin(25, 49)).to eql(
        '<img width="50" ' \
        'src="https://static.bpsd9.org/insignia/PNG/pins/Life_Member.png" />'
      )
    end

    it 'generates the correct 50-Year Life Member pin' do
      expect(membership_pin(25, 50)).to eql(
        '<img width="50" ' \
        'src="https://static.bpsd9.org/insignia/PNG/pins/50-Year_Life_Member.png" />'
      )
    end

    it 'generates the correct GB Member Emeritus pin' do
      expect(membership_pin(50, 50)).to eql(
        '<img width="50" ' \
        'src="https://static.bpsd9.org/insignia/PNG/pins/Governing_Board_Member_Emeritus.png" />'
      )
    end
  end
end
