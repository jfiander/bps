class RegistrationMailer < ApplicationMailer
  default from: 'support@bpsd9.org'

  def send_new(registration)
    @registration = registration
    @committee_chairs = get_committee_chairs
    @to_list = to_list

    mail(to: @to_list, subject: 'New registration')
  end

  def send_cancelled(registration)
    @registration = registration
    @committee_chairs = get_committee_chairs
    @to_list = to_list

    mail(to: @to_list, subject: 'Cancelled registration')
  end

  private
  def to_list
    if @registration.event.event_type.event_category == 'meeting'
      list = ['ao@bpsd9.org']
      list << if @registration.event.event_type.title == 'rendezvous'
        get_chair_email('Rendezvous')
      else
        get_chair_email('Meetings & Programs')
      end
    else
      list = ['seo@bpsd9.org', 'aseo@bpsd9.org']
      list << case @registration.event.event_type.event_category
      when 'seminar'
        get_chair_email('Seminars')
      when 'public'
        get_chair_email('ABC')
      when 'advanced_grade'
        get_chair_email('Advanced Grades')
      when 'elective'
        get_chair_email('Electives')
      end
    end

    list.flatten.uniq.reject(&:blank?)
  end

  def get_committee_chairs
    [
      Committee.includes(:user).where(department: 'administrative', name: ['Rendezvous', 'Meetings & Programs']),
      Committee.includes(:user).where(department: 'educational', name: ['Seminars', 'ABC', 'Advanced Grades', 'Electives'])
    ].flatten.reject(&:nil?)
  end

  def get_chair_email(name)
    @committee_chairs.find_all { |c| c.name == name }&.map { |c| c&.user&.email }
  end
end
