# frozen_string_literal: true

module Events::Update
private

  def update_attachments
    return nil unless event_type_param.in? %w[course seminar]

    Event.transaction do
      clear_before_time = Time.now

      update_includes
      update_topics
      update_instructors

      remove_old_attachments(clear_before_time)
    end
  end

  def update_includes
    clean_params[:includes].split("\n").map(&:squish).each do |i|
      CourseInclude.create(course: @event, text: i)
    end
  end

  def update_topics
    clean_params[:topics].split("\n").map(&:squish).each do |t|
      CourseTopic.create(course: @event, text: t)
    end
  end

  def update_instructors
    clean_params[:instructors].split("\n").map(&:squish).each do |u|
      user = find_user_for_instructor(user)
      EventInstructor.create(event: @event, user: user) if user.present?
    end
  end

  def find_user_for_instructor(user)
    if user.match?(%r{/})
      User.find_by(certificate: user.split('/').last.squish.upcase)
    else
      User.with_name(user).first
    end
  end

  def remove_old_attachments(clear_before_time)
    CourseInclude.where(course: @event).where(
      'updated_at < ?', clear_before_time
    ).destroy_all

    CourseTopic.where(course: @event).where(
      'updated_at < ?', clear_before_time
    ).destroy_all

    EventInstructor.where(event: @event).where(
      'updated_at < ?', clear_before_time
    ).destroy_all
  end
end
