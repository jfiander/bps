# frozen_string_literal: true

module FlagsHelper
  def officer_flags(rank, height = 100)
    content_tag(:div, class: 'officer-flags') do
      concat flag_image("flags/PNG/#{rank}.thumb.png", width: 150, height: height)
      concat tag(:br)
      concat dl_link('PNG', "flags/PNG/#{rank}.png")
      concat content_tag(:span, ' | ')
      concat dl_link('SVG', "flags/SVG/#{rank}.svg")
    end
  end

  def officer_insignia(rank)
    content_tag(:div, class: 'officer-insignia') do
      concat flag_image("flags/PNG/insignia/#{rank}.thumb.png", height: 75)
      concat tag(:br)
      concat dl_link('PNG', "flags/PNG/insignia/#{rank}.png")
      concat content_tag(:span, ' | ')
      concat dl_link('SVG', "flags/SVG/insignia/#{rank}.svg")
    end
  end

  def pennant(type)
    officer_flags(type, 25)
  end

  def grade_insignia(grade, height, edpro: false)
    edpro_tag = edpro ? '_edpro' : ''
    content_tag(:div, class: 'grade-insignia') do
      concat flag_image("insignia/PNG/grades/tr/#{grade}#{edpro_tag}.png", height: height)
      concat tag(:br)
      link_list('insignia/PNG/grades') { "#{grade}#{edpro_tag}" }
    end
  end

  def membership_insignia(membership)
    content_tag(:div, class: 'membership-insignia') do
      concat flag_image("insignia/PNG/membership/tr/#{membership}.png", width: 250)
      concat tag(:br)
      link_list('insignia/PNG/membership') { membership }
    end
  end

  def mm_insignia
    content_tag(:div, class: 'mm-insignia') do
      concat flag_image("insignia/PNG/mm.png", height: 30)
      concat tag(:br)
      concat dl_link('SVG', 'insignia/PNG/mm.png')
      concat content_tag(:span, ' | ')
      concat dl_link('SVG', 'insignia/SVG/mm.svg')
    end
  end

private

  def flag_image(path, **options)
    image_tag(@bucket.link(path), **options)
  end

  def dl_link(text, path)
    link_to(text, @bucket.link(path), disposition: 'inline', title: dl_link_title(text))
  end

  def dl_link_title(text)
    return unless text.in?(%w[T B W])

    {
      'T' => 'Transparent background',
      'B' => 'Black backgeround',
      'W' => 'White background'
    }[text]
  end

  def link_list(base_path)
    filename = yield
    concat content_tag(:span, 'PNG: ')
    concat dl_link('T', "#{base_path}/tr/#{filename}.png")
    concat content_tag(:span, ' ')
    concat dl_link('B', "#{base_path}/black/#{filename}.png")
    concat content_tag(:span, ' ')
    concat dl_link('W', "#{base_path}/white/#{filename}.png")
    concat content_tag(:span, ' | ')
    concat dl_link('SVG', "#{base_path.sub(/PNG/, 'SVG')}/#{filename}.svg")
  end
end
