# frozen_string_literal: true

module Events::QuickActions
  def expire
    rws('expire') { @event.expire! }
  end

  def archive
    rws('archive') { @event.archive! }
  end

  def remind
    @event.remind!
    flash[:success] = 'Successfully sent reminder emails.'
    redirect_to send("#{event_type_param}s_path")
  end

  def book
    @event.book!
    flash[:success] = "Successfully booked #{event_type_param}."
    redirect_to send("#{event_type_param}s_path")
  end

  def unbook
    @event.unbook!
    flash[:success] = "Successfully unbooked #{event_type_param}."
    redirect_to send("#{event_type_param}s_path")
  end

private

  def rws(verb)
    redirect_with_status(send("#{event_type_param}s_path"), object: event_type_param, verb: verb) do
      yield
    end
  end
end
