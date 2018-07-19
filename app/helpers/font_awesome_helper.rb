# frozen_string_literal: true

# FontAwesome 5 (Pro) Heler
module FontAwesomeHelper
  # html_safe: No user content
  def fa_layer(icons = {}, title: nil, grow: 0, css: '')
    # Add icons to the stack bottom to top
    #
    # Note: scaling ounters does not work well with :grow, so should use the
    # older "fa-3x" syntax in :css instead.
    span_top = "<span class='icon fa-layers fa-fw #{css}' title='#{title}'>"
    span_bottom = '</span>'

    icons.each { |i| i[:options] = combine_options(i, combine_grows(i, grow)) }

    output = span_top + parse_all(icons).join + span_bottom
    output.html_safe
  end

  def fa_icon(fa, options = {})
    if fa.is_a?(Hash)
      name = fa[:name]
      options = fa[:options]
    elsif fa.is_a?(String) || fa.is_a?(Symbol)
      name = fa.to_s
    else
      raise ArgumentError, 'Unexpected argument type.'
    end
    parse_icon(name, options).html_safe
  end

  def fa_span(fa, text = '', options = {})
    if fa.is_a?(Hash)
      type = fa[:type].to_sym
      text = fa[:text]
      options = fa[:options]
    elsif fa.is_a?(String) || fa.is_a?(Symbol)
      type = fa.to_s
    else
      raise ArgumentError, 'Unexpected argument type.'
    end
    parse_span(type, text, options).html_safe
  end

  private

  def parse_all(icons)
    icons.map do |icon|
      name = icon[:name]
      options = icon[:options] || {}

      if name.in? %i[counter text]
        parse_span(name, icon[:text], options)
      else
        parse_icon(name, options)
      end
    end
  end

  def parse_icon(name, options = {})
    options = fa_options(options)
    parse_options(options)
    title = options[:title]

    @classes << "fa-#{name}"
    @classes << "fa-#{size_x(options[:size])}" if options[:size].present?
    css = @classes.flatten.join(' ')
    transforms = @transforms.join(' ')

    "<i class='#{css}' data-fa-transform='#{transforms}' title='#{title}'></i>"
  end

  def parse_span(type, text, options = {})
    options.delete(:style)
    options = fa_options(options)
    parse_options(options)
    pos = options.delete(:position)
    position = long_position(pos) if pos.present?

    @classes << "fa-layers-#{type}"
    @classes << (position.present? ? "fa-layers-#{position}" : '')
    css = @classes.flatten.reject { |c| c.to_s.match?(/^fa.$/) }.join(' ')
    transforms = @transforms.join(' ')

    "<span class='#{css}' data-fa-transform='#{transforms}'>#{text}</span>"
  end

  def fa_options(options)
    default = { style: :solid, css: '', fa: '' }

    begin
      default.merge(options)
    # :nocov:
    rescue StandardError
      default
    end
    # :nocov:
  end

  def combine_grows(i, grow)
    if i.key?(:options) && i[:options].key?(:grow)
      i[:options][:grow] + grow
    else
      grow
    end
  end

  def combine_options(i, combined_grow)
    if i.key?(:options)
      i[:options].merge(grow: combined_grow)
    else
      { grow: combined_grow }
    end
  end

  def size_x(size)
    return '' unless size.present? || size == 1
    "#{size}x"
  end

  def long_position(position)
    return 'top-right' if position == :tr
    return 'top-left' if position == :tl
    return 'bottom-right' if position == :br
    return 'bottom-left' if position == :bl
  end

  def parse_options(options)
    parse_classes(options)
    parse_transforms(options)
  end

  def parse_classes(options)
    @classes = []
    @classes << parse_style(options[:style])
    @classes << options[:fa].to_s.split(' ').map { |c| "fa-#{c}" }
    @classes << options[:css].to_s.split(' ')
  end

  def parse_transforms(options)
    @transforms = []
    %i[grow shrink rotate up down left right].each do |transform|
      if options[transform].present?
        @transforms << "#{transform}-#{options[transform]}"
      end
    end
  end

  def parse_style(style)
    return 'fas' unless style.in?(%i[solid regular light brands])

    'fa' + {
      solid: 's',
      regular: 'r',
      light: 'l',
      brands: 'b'
    }[style]
  end
end
