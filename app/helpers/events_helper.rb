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
    @catalog ||= @all_events.find_all(&:show_in_catalog).sort_by do |e|
      [event_type(e).order_position, event_type(e).title]
    end.group_by { |e| event_type(e).event_category }
  end
end
