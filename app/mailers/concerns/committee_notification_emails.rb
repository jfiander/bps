# frozen_string_literal: true

module CommitteeNotificationEmails
  private

  def to_list
    list = if @registration.event.event_type.event_category == 'meeting'
             event_emails
           else
             education_emails
           end

    list.flatten.uniq.reject(&:blank?)
  end

  def event_emails
    list = ['ao@bpsd9.org']
    list << if @registration.event.event_type.title == 'rendezvous'
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
      seminar: 'Seminars',
      public: 'ABC',
      advanced_grade: 'Advanced Grades',
      elective: 'Electives',
      rendezvous: 'Rendezvous',
      meetings: 'Meetings & Programs'
    }[name]

    @committee_chairs.find_all { |c| c.name == name }&.map { |c| c&.user&.email }
  end
end
