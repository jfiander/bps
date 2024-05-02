# frozen_string_literal: true

module FlagsHelper
  RANK_COLORS = {
    red: %w[PORTCAP FLEETCAP LT FLT LTC DAIDE DLT DFLT DLTC VC],
    blue: %w[1LT CDR D1LT DC NAIDE NFLT STFC RC CC],
    gold: %w[1LT LTC CDR D1LT DLTC DC STFC RC VC CC],
    silver: %w[LTC CDR DLTC DC STFC RC VC CC]
  }.freeze

  def officer_flags(rank, height = 100)
    content_tag(:div, class: 'officer-flags') do
      concat flag_image("flags/PNG/#{rank}.thumb.png", width: 150, height: height)
      concat tag.br
      concat dl_link('PNG', "flags/PNG/#{rank}.png")
      concat content_tag(:span, ' | ')
      concat dl_link('SVG', "flags/SVG/#{rank}.svg")
    end
  end

  def officer_insignia(rank)
    content_tag(:div, class: 'officer-insignia') do
      concat flag_image("flags/PNG/insignia/#{rank}.thumb.png", height: 75)
      concat tag.br
      officer_insignia_links(rank, 'png')
      concat content_tag(:span, ' | ')
      officer_insignia_links(rank, 'svg')
    end
  end

  def pennant(type)
    officer_flags(type, 25)
  end

  def grade_insignia(grade, height, edpro: false)
    edpro_tag = edpro ? '_edpro' : ''
    content_tag(:div, class: 'grade-insignia') do
      concat flag_image("insignia/PNG/grades/tr/#{grade}#{edpro_tag}.png", height: height)
      concat tag.br
      link_list('insignia/PNG/grades') { "#{grade}#{edpro_tag}" }
    end
  end

  def membership_insignia(membership)
    content_tag(:div, class: 'membership-insignia') do
      concat flag_image("insignia/PNG/membership/tr/#{membership}.png", width: 250)
      concat tag.br
      link_list('insignia/PNG/membership') { membership }
    end
  end

  def mm_insignia
    content_tag(:div, class: 'mm-insignia') do
      concat flag_image('insignia/PNG/mm.png', height: 30)
      concat tag.br
      concat dl_link('PNG', 'insignia/PNG/mm.png')
      concat content_tag(:span, ' | ')
      concat dl_link('SVG', 'insignia/SVG/mm.svg')
    end
  end

  def gb_insignia
    content_tag(:div, class: 'gb-insignia') do
      concat flag_image('insignia/PNG/membership/tr/gb.png', height: 45)
      concat tag.br
      concat dl_link('PNG', 'insignia/PNG/membership/tr/gb.png')
    end
  end

  def gb_emeritus_insignia
    content_tag(:div, class: 'gb-emeritus-insignia') do
      concat flag_image('insignia/PNG/membership/tr/gb_emeritus.png', height: 45)
      concat tag.br
      concat dl_link('PNG', 'insignia/PNG/membership/tr/gb_emeritus.png')
    end
  end

  def membership_pin(mm, years)
    membership =
      if mm >= 50
        'Governing_Board_Member_Emeritus'
      elsif mm >= 25
        years >= 50 ? '50-Year_Life_Member' : 'Life_Member'
      elsif years >= 50
        '50-Year_Member'
      elsif years >= 25
        '25-Year_Member'
      else
        'Member'
      end

    image_tag("https://flags.aws.usps.org/pins/PNG/trimmed/100/#{membership}.png", width: 80)
  end

private

  def flag_image(path, **options)
    image_tag(BPS::S3.new(:static).link(path), **options)
  end

  def dl_link(text, path, title: nil, css: nil)
    link_to(
      text, BPS::S3.new(:static).link(path),
      disposition: 'inline',
      title: title || dl_link_title(text),
      class: css
    )
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
    concat dl_link('SVG', "#{base_path.sub('PNG', 'SVG')}/#{filename}.svg")
  end

  def officer_insignia_links(rank, format)
    return single_insignia_link(rank, format) if number_of_colors(rank) == 1

    concat "#{format.upcase}: "
    concat safe_join(RANK_COLORS.map do |color, ranks|
      color_dir = color.in?(%i[red blue]) ? '' : "#{color}/"
      path = "flags/#{format.upcase}/insignia/#{color_dir}#{rank}.#{format}"
      dl_link(color[0].upcase, path, title: color.to_s.titleize, css: color) if rank.in?(ranks)
    end.compact, ' ')
  end

  def single_insignia_link(rank, format)
    concat dl_link(format.upcase, "flags/#{format.upcase}/insignia/#{rank}.#{format}")
  end

  def number_of_colors(rank)
    RANK_COLORS.count { |_color, ranks| rank.in?(ranks) }
  end
end
