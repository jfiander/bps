# FontAwesome 5 (Pro) Heler
module FontAwesomeHelper
  def fa_layer(icons = {}, title: nil, grow: 0, css: '')
    # Add icons to the stack bottom to top
    #
    # Note: scaling ounters does not work well with :grow, so should use the
    # older "fa-3x" syntax in :css instead.
    span_top = "<span class='icon fa-layers fa-fw #{css}' title='#{title}'>"
    span_bottom = '</span>'

    icons.each do |i|
      combined_grow = if i.key?(:options) && i[:options].key?(:grow)
                        i[:options][:grow] + grow
                      else
                        grow
                      end

      if i.key?(:options)
        i[:options] = i[:options].merge(grow: combined_grow)
      else
        i[:options] = { grow: combined_grow }
      end
    end

    output = span_top + parse_all(icons).join + span_bottom
    output.html_safe
  end

  def fa_icon(fa, options = {})
    if fa.is_a?(Hash)
      name = fa[:name]
      options = fa[:options]
    elsif fa.is_a?(String)
      name = fa
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
      type = fa.to_sym
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

      if name.in? [:counter, :text]
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
    css = @classes.flatten.join(' ')
    transforms = @transforms.join(' ')

    "<i class='#{css}' data-fa-transform='#{transforms}' title='#{title}'></i>"
  end

  def parse_span(type, text, options = {})
    options.delete(:style)
    options = fa_options(options)
    parse_options(options)
    position = long_position(options.delete(:position))

    @classes << "fa-layers-#{type}"
    @classes << position.present? ? "fa-layers-#{position}" : ''
    css = @classes.flatten.reject { |c| c.match(/^fa.$/) }.join(' ')
    transforms = @transforms.join(' ')

    "<span class='#{css}' data-fa-transform='#{transforms}'>#{text}</span>"
  end

  def fa_options(options)
    default = { style: :solid, css: '', fa: '' }

    begin
      default.merge(options)
    rescue
      default
    end
  end

  def size_x(size)
    return '' unless size.present? || size == 1
    "-#{size}x"
  end

  def long_position(position)
    return 'top-right' if position == :tr
    return 'top-left' if position == :tl
    return 'bottom-right' if position == :br
    return 'bottom-left' if position == :bl
  end

  def parse_options(options)
    @classes = []
    @transforms = []

    @classes << 'fa' + case options[:style]
                       when :solid
                         's'
                       when :regular
                         'r'
                       when :light
                         'l'
                       when :brands
                         'b'
                       else
                         's'
                       end
    @classes << options[:fa].to_s.split(' ').map { |c| "fa-#{c}" }
    @classes << options[:css].to_s.split(' ')

    @transforms << "grow-#{options[:grow]}" if options[:grow].present?
    @transforms << "shrink-#{options[:shrink]}" if options[:shrink].present?
    @transforms << "rotate-#{options[:rotate]}" if options[:rotate].present?
    @transforms << "up-#{options[:up]}" if options[:up].present?
    @transforms << "down-#{options[:down]}" if options[:down].present?
    @transforms << "rotate-#{options[:left]}" if options[:left].present?
    @transforms << "right-#{options[:right]}" if options[:right].present?
  end
end
