module EventsHelper
  def event_type(event)
    @event_types.find_all { |e| e.id == event.event_type_id }.first
  end

  def event_prereq(event)
    @event_types.find_all { |e| e.id == event.prereq_id }.first
  end

  def event_instructors(event)
    @users.find_all do |u|
      u.id.in?(@event_instructors.find_all do |ei|
        ei.event_id == event.id
      end.map(&:user_id))
    end
  end

  def course_topics(event)
    @course_topics.find_all { |ct| ct.course_id == event.id }
  end

  def course_includes(event)
    @course_includes.find_all { |ci| ci.course_id == event.id }
  end

  def preload_events
    @users ||= User.all
    @all_events ||= Event.order(:start_at)
    @course_topics ||= CourseTopic.all
    @course_includes ||= CourseInclude.all
    @event_instructors ||= EventInstructor.all
    @event_types ||= EventType.all
    @locations ||= Location.searchable
    @catalog ||= @all_events.find_all(&:show_in_catalog).sort_by do |e|
      [event_type(e).order_position, event_type(e).title]
    end.group_by { |e| event_type(e).event_category }
  end

  def render_both_tables(events, long_form: false)
    %i[desktop mobile].map do |t|
      render("events/#{t}/table", events: events, long_form: long_form)
    end.join.html_safe
  end

  def get_events(type, scope = :current)
    @scoped_events ||= {
      current: @all_events.find_all { |e| !e.expired? },
      expired: @all_events.find_all(&:expired?)
    }

    @event_types ||= EventType.all
    @event_type_ids ||= @event_types.group_by(&:event_category).map do |c, t|
      { c => t.map(&:id) }
    end.reduce({}, :merge)

    case type
    when :course
      courses = {
        public: @scoped_events[scope].find_all do |c|
          c.event_type_id.in?(@event_type_ids['public'])
        end,
        advanced_grade: @scoped_events[scope].find_all do |c|
          c.event_type_id.in?(@event_type_ids['advanced_grade'])
        end,
        elective: @scoped_events[scope].find_all do |c|
          c.event_type_id.in?(@event_type_ids['elective'])
        end
      }

      courses.all?(&:blank?) ? [] : courses
    when :seminar
      @scoped_events[scope].find_all do |c|
        c.event_type_id.in?(@event_type_ids['seminar'])
      end
    when :event
      @scoped_events[scope].find_all do |c|
        c.event_type_id.in?(@event_type_ids['meeting'])
      end
    end
  end
end
