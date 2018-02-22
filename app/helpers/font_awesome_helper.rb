module FontAwesomeHelper
  def fa_layer(icons = {}, title: nil)
    # Add icons to the stack bottom to top
    span_top = "<span class='icon fa-layers fa-fw' title='#{title}'>"
    span_bottom = '</span>'

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

      parse_icon(name, options)
    end
  end

  def parse_icon(name, options = {})
    options = default_icon_options.merge(options) rescue default_icon_options
    parse_classes(options)
    parse_transforms(options.slice(
      :grow, :shrink, :rotate, :up, :down, :left, :right
    ))
    title = options[:title] if options.has_key?(:title)

    @classes << "fa-#{name}"
    css = @classes.flatten.join(' ')
    transforms = @transforms.join(' ')

    "<i class='#{css}' data-fa-transform='#{transforms}' title='#{title}'></i>"
  end

  def parse_span(type, text, options = {})
    options = default_icon_options.merge(options) rescue default_icon_options
    parse_classes(options)
    parse_transforms(options.slice(
      :grow, :shrink, :rotate, :up, :down, :left, :right
    ))

    @classes << "fa-layers-#{type}"
    css = @classes.join(' ')
    transforms = @transforms.join(' ')

    "<span class='#{css}' data-fa-transform='#{transforms}'>#{text}</span>"
  end

  def default_icon_options
    { style: :solid, css: '', fa: '', size: 1 }
  end

  def size_x(size)
    return '' unless size.present? || size == 1
    "-#{size}x"
  end

  def parse_classes(options)
    @classes = []
    @classes << 'fa' + case options[:style]
                       when :solid
                         's'
                       when :regular
                         'r'
                       when :light
                         'l'
                       else
                         's'
                       end
    @classes << options[:fa].to_s.split(' ').map { |c| "fa-#{c}" }
    @classes << options[:css].to_s.split(' ')
  end

  def parse_transforms(options)
    @transforms = []
    @transforms << "grow-#{options[:grow]}" if options[:grow].present?
    @transforms << "shrink-#{options[:shrink]}" if options[:shrink].present?
    @transforms << "rotate-#{options[:rotate]}" if options[:rotate].present?
    @transforms << "up-#{options[:up]}" if options[:up].present?
    @transforms << "down-#{options[:down]}" if options[:down].present?
    @transforms << "rotate-#{options[:left]}" if options[:left].present?
    @transforms << "right-#{options[:right]}" if options[:right].present?
  end
end
