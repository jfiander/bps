class RegistrationMailer < ApplicationMailer
  def registered(registration)
    @registration = registration
    @committee_chairs = load_committee_chairs
    @to_list = to_list

    mail(to: @to_list, subject: 'New registration')
  end

  def cancelled(registration)
    @registration = registration
    @committee_chairs = load_committee_chairs
    @to_list = to_list

    mail(to: @to_list, subject: 'Cancelled registration')
  end

  def confirm(registration)
    @registration = registration
    @signature = signature_for_confirm
    to = @registration&.user&.email || @registration.email
    from = "\"#{@signature[:name]}\" <#{@signature[:email]}>"
    attach_pdf if attachable?

    mail(to: to, from: from, subject: 'Registration confirmation')
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
      list << @registration.event.instructors.map(&:email)
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

  def load_committee_chairs
    [
      Committee.get(:administrative, 'Rendezvous', 'Meetings & Programs'),
      Committee.get(:educational, 'Seminars', 'ABC', 'Advanced Grades', 'Electives')
    ].flatten.reject(&:nil?)
  end

  def get_chair_email(name)
    @committee_chairs.find_all { |c| c.name == name }&.map { |c| c&.user&.email }
  end

  def signature_for_confirm
    if @registration.event.category == :event
      ao_signature
    else
      seo_signature
    end
  end

  def ao_signature
    {
      office: 'Administrative',
      name: BridgeOffice.find_by(office: 'administrative').user.full_name,
      email: 'ao@bpsd9.org'
    }
  end

  def seo_signature
    {
      office: 'Educational',
      name: BridgeOffice.find_by(office: 'educational').user.full_name,
      email: 'seo@bpsd9.org'
    }
  end

  def attach_pdf
    flyer = @registration.event.flyer
    data = Paperclip.io_adapters.for(flyer).read
    name = @registration.event.event_type.display_title.delete("' ")
    attachments["#{name}.pdf"] = data
  end

  def attachable?
    @registration.event.flyer.present? &&
      @registration.event.flyer.content_type == 'application/pdf'
  end
end
