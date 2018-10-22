# frozen_string_literal: true

module EventsHelper
  def event_type(event)
    @event_types.find_all { |e| e.id == event.event_type_id }.first
  end

  def event_prereq(event)
    @event_types.find_all { |e| e.id == event.prereq_id }.first
  end

  def event_instructors(event)
    @event_instructors.find_all do |ei|
      ei.event_id == event.id
    end.map(&:user)
  end

  def course_topics(event)
    @course_topics.find_all { |ct| ct.course_id == event.id }
  end

  def course_includes(event)
    @course_includes.find_all { |ci| ci.course_id == event.id }
  end

  def preload_events
    preload_event_data
    preload_attachments
    catalog_list
  end

  def preload_event_data
    @all_events ||= Event.order(:start_at)
    @locations ||= Location.searchable
    @event_types ||= EventType.ordered
  end

  def preload_attachments
    @course_topics ||= CourseTopic.all
    @course_includes ||= CourseInclude.all
    @event_instructors ||= EventInstructor.includes(:user).all
  end

  def catalog_list
    return @catalog if @catalog.present?

    catalog = @all_events.find_all(&:show_in_catalog).sort_by do |e|
      [event_type(e).order_position, event_type(e).title]
    end
    @catalog = catalog.group_by { |e| event_type(e).event_category }
  end

  def get_events(type, scope = :current)
    @event_types ||= EventType.ordered

    case type.to_s
    when 'course'
      courses = scoped_courses(scope)

      courses.all?(&:blank?) ? [] : courses
    when 'seminar'
      filter_scoped('seminar', scope)
    when 'event'
      filter_scoped('meeting', scope)
    end
  end

  def scoped_events
    expired = Date.today.last_year.beginning_of_year
    @scoped_events ||= {
      current: @all_events.find_all { |e| !e.expired? },
      expired: @all_events.find_all { |e| e.expired? && e.start_at >= expired }
    }
  end

  def event_type_ids
    @event_type_ids ||= @event_types.group_by(&:event_category).map do |c, t|
      { c => t.map(&:id) }
    end.reduce({}, :merge)
  end

  def scoped_courses(scope = :current)
    {
      public: filter_scoped('public', scope),
      advanced_grade: filter_scoped('advanced_grade', scope),
      elective: filter_scoped('elective', scope)
    }
  end

  def filter_scoped(type, scope = :current)
    scoped_events[scope].find_all do |c|
      c.event_type_id.in?(event_type_ids[type])
    end
  end

  def event_action_link(event, path, **options)
    return if options.key?(:if) && !options[:if]
    return if options.key?(:expired) && options[:expired] != event&.expired?

    options = event_action_link_defaults(options[:css]).merge(options)
    confirm = options.delete(:confirm)
    options[:data][:confirm] = confirm if confirm.present?
    icon = event_action_link_icon(options)

    generate_event_action_link(event, path, icon, options)
  end

  def reg_override_icon(reg)
    options = reg_override_options(reg)
    icon = FA::Icon.p(
      'file-invoice-dollar',
      style: reg_override_style(reg), css: options[:css], title: options[:title]
    )
    reg.paid? ? icon : link_to(override_cost_path(reg.id)) { icon }
  end

  def reg_override_style(reg)
    reg.override_cost.present? ? :solid : :regular
  end

  def reg_override_verb(reg)
    reg.override_cost.present? ? 'Update' : 'Set'
  end

  def reg_override_options(reg)
    if reg.paid?
      { title: 'Registration has already been paid', css: 'gray' }
    else
      { title: "#{reg_override_verb(reg)} override cost", css: 'green' }
    end
  end

private

  def event_action_link_defaults(css)
    {
      icon: '', text: '', class: "control #{css}",
      confirm: '', data: {}, icon_options: { fa: :fw, style: :regular }
    }
  end

  def event_action_link_icon(options)
    FA::Icon.p(
      options[:icon], **options.delete(:icon_options)
    ) + options[:text].titleize
  end

  def generate_event_action_link(event, path, icon, options)
    if path.present? && path.match?(/_path/)
      link_to(send(path, event), **options) { icon }
    elsif path.present?
      link_to(path, **options) { icon }
    else
      icon
    end
  end
end
