# frozen_string_literal: true

module CommitteeNotificationEmails
  # This module defines no public methods.
  def _; end

private

  def to_list
    if @registration.event.event_type.event_category == 'meeting'
      event_emails
    else
      education_emails
    end.flatten.uniq.reject(&:blank?)
  end

  def event_emails
    event_type = @registration.event.event_type
    list = ['ao@bpsd9.org']
    if event_type.committees.any?
      list.tap { |l| event_type.dept_heads.each { |c| l << c.email } }
      list.tap { |l| event_type.committees.each { |c| l << c.user.email } }
    else
      list << meeting_or_rendezvous_email
    end
  end

  def meeting_or_rendezvous_email
    if @registration.event.event_type.title == 'rendezvous'
      get_chair_email('rendezvous')
    else
      get_chair_email('meetings')
    end
  end

  def education_emails
    list = ['seo@bpsd9.org', 'aseo@bpsd9.org']
    list << @registration.event.instructors.map(&:email)
    list << get_chair_email(@registration.event.event_type.event_category)
  end

  def load_committee_chairs
    [
      Committee.get(:administrative, 'Rendezvous', 'Meetings & Programs'),
      Committee.get(:educational, 'Seminars', 'ABC', 'Advanced Grades', 'Electives')
    ].flatten.reject(&:nil?)
  end

  def get_chair_email(name)
    name = {
      'seminar' => 'Seminars',
      'public' => 'ABC',
      'advanced_grade' => 'Advanced Grades',
      'elective' => 'Electives',
      'rendezvous' => 'Rendezvous',
      'meetings' => 'Meetings & Programs'
    }[name]

    @committee_chairs ||= load_committee_chairs
    @committee_chairs.find_all { |c| c.name == name }&.map { |c| c&.user&.email }
  end
end
