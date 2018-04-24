module EventsMethods
  private

  def event_params
    params.require(:event).permit(
      %i[
        id event_type_id description cost member_cost requirements
        location_id map_link start_at length sessions flyer
        cutoff_at expires_at prereq_id allow_member_registrations
        allow_public_registrations show_in_catalog
      ]
    )
  end

  def clean_params
    params.permit(:id, :includes, :topics, :instructors, :locations)
  end

  def event_type_title_from(formatted)
    formatted.to_s.downcase.tr(' ', '_').to_sym
  end

  def after_save_event(mode: :added)
    update_attachments
    redirect_to(
      send("#{params[:type]}s_path"),
      success: "Successfully #{mode} #{params[:type]}."
    )
  end

  def failed_to_save_event(mode: :add)
    path = {
      add: :create,
      modify: :update
    }[mode]

    flash.now[:alert] = "Unable to #{mode} #{params[:type]}."
    flash.now[:error] = @event.errors.full_messages
    @submit_path = send("#{path}_#{params[:type]}_path")
    @edit_mode = mode.to_s.titleize
    @event_types = EventType.selector(params[:type])
    render :new
  end

  def find_event
    @event = Event.includes(:event_instructors, :instructors)
                  .find_by(id: clean_params[:id])

    load_attachments if @event.course? || @event.seminar?
  end

  def prepare_form
    @event_types = EventType.selector(params[:type])
    @event_title = params[:type].to_s.titleize
    @edit_mode = 'Add'
  end

  def location_names
    @locations = Location.all.map(&:display)
  end

  def set_create_path
    @submit_path = send("create_#{params[:type]}_path")
  end

  def update_attachments
    return nil unless params[:type].in? %i[course seminar]

    Event.transaction do
      clear_before_time = Time.now

      clean_params[:includes].split("\n").map(&:squish).each do |i|
        CourseInclude.create(course: @event, text: i)
      end

      clean_params[:topics].split("\n").map(&:squish).each do |t|
        CourseTopic.create(course: @event, text: t)
      end

      clean_params[:instructors].split("\n").map(&:squish).each do |u|
        user = if u.match?(%r{/})
                 User.find_by(certificate: u.split('/').last.squish.upcase)
               else
                 User.with_name(u).first
               end
        EventInstructor.create(event: @event, user: user) if user.present?
      end

      remove_old_attachments(clear_before_time)
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

  def check_for_blank
    return unless event_params['event_type_id'].blank?

    # This doesn't handle missing event_type on update correctly.

    prepare_form
    @submit_path = send("create_#{params[:type]}_path")
    @event = Event.new(event_params)
    @course_topics = clean_params[:includes]
    @course_includes = clean_params[:topics]
    @instructors = clean_params[:instructors]
    flash[:alert] = "You must select a valid #{params[:type]} name."
    render :new
  end

  def load_registrations
    @registered = Registration.includes(:user).where(user_id: current_user.id)
                              .map { |r| { r.event_id => r.id } }
                              .reduce({}, :merge)
  end

  def load_attachments
    @course_includes = CourseInclude.where(course_id: @event.id).map(&:text)
                                    .join("\n")

    @course_topics = CourseTopic.where(course_id: @event.id).map(&:text)
                                .join("\n")

    @instructors = EventInstructor.where(event_id: @event.id).map(&:user)
                                  .map do |u|
                                    "#{u.simple_name} / #{u.certificate}"
                                  end.join("\n")
  end
end
