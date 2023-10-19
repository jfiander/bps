# frozen_string_literal: true

class RegistrationsController < ApplicationController
  title!('Registration')

  secure!(only: :destroy)

  before_action :redirect_if_existing, only: %i[new create]

  def show
    @registration = Registration.find(params[:id])
    @event = @registration.event
  end

  def new
    @registration = Registration.new(event_id: params[:event_id])
    @event = Event.find(params[:event_id])
  end

  def create
    additional_registrations = params[:registration].delete(:additional_registrations_attributes)

    registration = Registration.new(registration_params.merge(user: current_user))

    registration_options_params.each do |_description, option_id|
      registration.registration_options.build(event_option_id: option_id)
    end

    process_additional_registrations(registration, additional_registrations)

    registration.save!

    redirect_to(registration_path(registration))
  end

  def destroy
    registration = Registration.find(params[:id])

    text = registration.additional_registrations.any? ? 'these registrations' : 'this registration'

    Registration.transaction do
      registration.additional_registrations.destroy_all
      registration.destroy
    end

    flash[:success] = "You have successfully cancelled #{text}."

    redirect_to root_path
  end

private

  def registration_params
    params.require(:registration).permit(:event_id, :name, :email, :phone)
  end

  def registration_options_params
    params.permit(event_selections: {})[:event_selections]
  end

  def redirect_if_existing
    existing = Registration.find_by(event_id: params[:event_id], user: current_user)
    redirect_to(existing) if existing
  end

  def process_additional_registrations(registration, additional_registrations)
    return unless additional_registrations

    additional_registrations.each_value do |details|
      user = User.find_by(certificate: details[:certificate]) if details[:certificate].present?
      additional = registration.additional_registrations.build(
        event_id: registration.event_id, name: details[:name], user: user
      )

      # details[:selections].each do |selection|
      #
      # end
      selection = details[:selections] # DEV
      additional.registration_options.build(event_option_id: selection)
    end
  end
end
