# frozen_string_literal: true

module NavigationHelper
  def link(title = nil, options = {})
    @options = default_options.merge(options).merge(title: title)
    return unless show_menu?(@options.except(:suffix, :active, :fa, :css_class))

    @link_options = { class: @options[:permit].to_s }
    @fa = @options[:fa]

    parse_nav_presets
    parse_nav_classes
    generate_link
  end

  private

  def default_options
    {
      permit: nil,
      path: nil,
      show_when: :always,
      suffix: '',
      active: false,
      fa: nil,
      css_class: ''
    }
  end

  def parse_nav_presets
    if @options[:title] == :login_or_logout && user_signed_in?
      @options[:title] = 'Logout'
      @options[:path] = destroy_user_session_path
      @link_options = { method: :delete, class: 'red' }
      @fa = { name: 'sign-out', options: { style: :regular } }
    elsif @options[:title] == :login_or_logout
      @options[:title] = 'Member Login'
      @options[:path] = new_user_session_path
      @link_options = { class: 'members' }
      @fa = { name: 'sign-in', options: { style: :regular } }
    elsif @options[:show_when] == :logged_in
      @link_options = { class: 'members' }
    end
  end

  def parse_nav_classes
    if @options[:title].is_a?(Symbol)
      @options[:title] = @options[:title].to_s.titleize
    end
    @classes = [@options[:css_class]]
    @classes << @options[:permit] if @options[:permit]
    @classes << 'active' if @options[:active]
    @css_class = @classes.join(' ')
  end

  def generate_link
    icon_tag = @fa.present? ? FA::Icon.new(@fa).safe : ''
    @link_options = @link_options.merge(title: @options[:title])
    link_to(@options[:path], @link_options) do
      content_tag(:li, class: @css_class) do
        icon_tag + @options[:title]
      end
    end + @options[:suffix]
  end

  def show_menu?(title: nil, permit:, show_when:, path:)
    show_when == :always ||
      always_show_menu?(title) ||
      !hide_menu?(permit: permit, show_when: show_when, path: path)
  end

  def hide_menu?(permit:, show_when:, path:)
    path.blank? ||
      requires_signed_in?(show_when) ||
      requires_signed_out?(show_when) ||
      user_not_permitted?(permit)
  end

  def always_show_menu?(title)
    title.in?(%i[home login_or_logout])
  end

  def requires_signed_in?(show_when)
    show_when == :logged_in && !user_signed_in?
  end

  def requires_signed_out?(show_when)
    show_when == :logged_out && user_signed_in?
  end

  def user_not_permitted?(permit)
    permit.present? && !current_user&.permitted?(permit)
  end
end
