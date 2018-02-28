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
    @all_events ||= Event.order(:start_at)
    @catalog ||= @all_events.find_all(&:show_in_catalog).group_by(&:category)
    @course_topics ||= CourseTopic.all
    @course_includes ||= CourseInclude.all
    @users ||= User.all
    @event_instructors ||= EventInstructor.all
    @event_types ||= EventType.all
  end
end
