# frozen_string_literal: true

class ApplicationController < ActionController::Base
  force_ssl if: :ssl_configured?
  protect_from_forgery with: :exception
  add_flash_types :success, :error

  include Application::Meta
  include Application::LayoutAndFormatting
  include MarkdownHelper
  include FontAwesomeHelper
  include BucketHelper
  include ApplicationHelper
  helper_method :static_bucket, :files_bucket, :bilge_bucket, :photos_bucket

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :pick_header_image
  before_action :meta_tags
  before_action :set_paper_trail_whodunnit
  before_action :time_formats
  before_action :prerender_for_layout

  after_action { flash.discard if request.xhr? }

  def self.render_markdown_views
    before_action :render_markdown, only: MarkdownHelper::VIEWS[controller_name]
    MarkdownHelper::VIEWS[controller_name]&.each { |m| define_method(m) {} }
  end

  private

  def ssl_configured?
    Rails.env.production?
  end

  def handle_unverified_request
    flash[:alert] = 'Sorry, please try that again.'
    redirect_to :back
  end

  def require_permission(*roles, strict: false)
    return if current_user&.permitted?(*roles, strict: strict)
    redirect_to root_path
    # before_action only: [:method_1] { require_permission(:role_name) }
  end

  def authenticate_user!(*args)
    return super(*args) if user_signed_in?
    flash[:referrer] = request.original_fullpath
    flash[:notice] = 'You must login to continue.'
    redirect_to new_user_session_path
  end

  def authenticate_inviter!
    unless current_user&.permitted?(:users)
      redirect_to root_path
      return
    end

    super
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: %i[profile_photo rank first_name last_name]
    )
  end

  def markdown_views?
    defined?(MARKDOWN_EDITABLE_VIEWS)
  end
end
