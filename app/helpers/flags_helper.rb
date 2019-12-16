# frozen_string_literal: true

module FlagsHelper
  def officer_flags(rank, height = 100)
    content_tag(:div, class: 'officer-flags') do
      concat image_tag(@bucket.link("flags/PNG/#{rank}.thumb.png"), width: 150, height: height)
      concat tag(:br)
      concat link_to('PNG', @bucket.link("flags/PNG/#{rank}.png"), disposition: 'inline')
      concat content_tag(:span, ' | ')
      concat link_to('SVG', @bucket.link("flags/SVG/#{rank}.svg"), disposition: 'inline')
    end
  end

  def officer_insignia(rank)
    content_tag(:div, class: 'officer-insignia') do
      concat image_tag(@bucket.link("flags/PNG/insignia/#{rank}.thumb.png"), height: 75)
      concat tag(:br)
      concat link_to('PNG', @bucket.link("flags/PNG/insignia/#{rank}.png"), disposition: 'inline')
      concat content_tag(:span, ' | ')
      concat link_to('SVG', @bucket.link("flags/SVG/insignia/#{rank}.svg"), disposition: 'inline')
    end
  end

  def pennant(type)
    officer_flags(type, 25)
  end

  def grade_insignia(grade, height, edpro: false)
    edpro_tag = edpro ? '_edpro' : ''
    content_tag(:div, class: 'grade-insignia') do
      concat image_tag(@bucket.link("insignia/PNG/grades/tr/#{grade}#{edpro_tag}.png"), height: height)
      concat tag(:br)
      concat content_tag(:span, 'PNG: ')
      concat link_to('T', @bucket.link("insignia/PNG/grades/tr/#{grade}#{edpro_tag}.png"), disposition: 'inline', title: 'Transparent background')
      concat content_tag(:span, ' ')
      concat link_to('B', @bucket.link("insignia/PNG/grades/black/#{grade}#{edpro_tag}.png"), disposition: 'inline', title: 'Black background')
      concat content_tag(:span, ' ')
      concat link_to('W', @bucket.link("insignia/PNG/grades/white/#{grade}#{edpro_tag}.png"), disposition: 'inline', title: 'White background')
      concat content_tag(:span, ' | ')
      concat link_to('SVG', @bucket.link("insignia/SVG/grades/#{grade}#{edpro_tag}.svg"), disposition: 'inline')
    end
  end

  def membership_insignia(membership)
    content_tag(:div, class: 'membership-insignia') do
      concat image_tag(@bucket.link("insignia/PNG/membership/tr/#{membership}.png"), width: 250)
      concat tag(:br)
      concat content_tag(:span, 'PNG: ')
      concat link_to('T', @bucket.link("insignia/PNG/membership/tr/#{membership}.png"), disposition: 'inline', title: 'Transparent background')
      concat content_tag(:span, ' ')
      concat link_to('B', @bucket.link("insignia/PNG/membership/black/#{membership}.png"), disposition: 'inline', title: 'Black background')
      concat content_tag(:span, ' ')
      concat link_to('W', @bucket.link("insignia/PNG/membership/white/#{membership}.png"), disposition: 'inline', title: 'White background')
      concat content_tag(:span, ' | ')
      concat link_to('SVG', @bucket.link("insignia/SVG/membership/#{membership}.svg"), disposition: 'inline')
    end
  end

  def mm_insignia
    content_tag(:div, class: 'mm-insignia') do
      concat image_tag(@bucket.link("insignia/PNG/mm.png"), height: 30)
      concat tag(:br)
      concat link_to('PNG', @bucket.link("insignia/PNG/mm.png"), disposition: 'inline')
      concat content_tag(:span, ' | ')
      concat link_to('SVG', @bucket.link("insignia/SVG/mm.svg"), disposition: 'inline')
    end
  end
end
