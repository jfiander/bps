# frozen_string_literal: true

class RosterController < ApplicationController
  secure!(:users, :roster)

  title!('Roster Information')

  before_action :users, only: %i[new create edit update]
  before_action :record, only: %i[edit update destroy]

  def show
    @collection = model.all
  end

  def new
    @record = model.new
  end

  def edit
    render :new
  end

  def create
    @record = model.new(formatted_params)
    check_and_redirect(:create, :new) { @record.save }
  end

  def update
    check_and_redirect(:update, :edit) { @record.update(formatted_params) }
  end

  def destroy
    check_and_redirect(:remove) { @record.destroy }
  end

private

  def safe_params
    params.permit(:id, :year)
  end

  def record_id
    clean_params[:id]
  rescue StandardError
    safe_params[:id]
  end

  def record
    @record = model.find_by(id: record_id)
  end

  def users
    @users ||= User.alphabetized.unlocked
  end

  def formatted_params
    return clean_params if clean_params[:year].blank? || clean_params[:year].is_a?(Date)

    date = Date.strptime(clean_params[:year].to_s, '%Y')
    clean_params.to_h.merge(year: date)
  end

  def check_and_redirect(verb, render_sym = nil)
    success = yield if block_given?
    flash[:success] = "Successfully #{verb}d #{model}!" if success
    flash[:alert] = "Unable to #{verb} #{model}." unless success

    render_or_redirect(success, render_sym)
  end

  def render_or_redirect(success, render_sym)
    return render(render_sym) if !success && render_sym.present?

    redirect_to send("#{model.to_s.underscore.tr('/', '_')}s_path")
  end
end
