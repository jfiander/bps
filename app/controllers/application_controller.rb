class ApplicationController < ActionController::Base
  force_ssl if: :ssl_configured?
  protect_from_forgery with: :exception
  add_flash_types :success, :error

  include MarkdownHelper
  include FontAwesomeHelper
  include BucketHelpers
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

  def require_permission(*role)
    redirect_to root_path and return unless current_user&.permitted?(*role)
    # before_action only: [:method_1] { require_permission(:role_name) }
  end

  def authenticate_user!(*args)
    return super(*args) if user_signed_in?
    redirect_to new_user_session_path, flash: { referrer: request.original_fullpath }
  end

  def authenticate_inviter!
    redirect_to root_path and return unless current_user&.permitted?(:users)
    super
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [:profile_photo, :rank, :first_name, :last_name]
    )
  end

  def time_formats
    @long_time_format = '%a %d %b %Y @ %H%M %Z'
    @medium_time_format = '%-m/%-d/%Y @ %H%M'
    @short_time_format = '%-m/%-d @ %H%M'
    @duration_format = '%-kh %Mm'
  end

  def pick_header_image
    @header_image = files_bucket.link(HeaderImage.random&.path(:desktop))
    @header_logo = static_bucket.link('logos/ABC.tr.300.png')
    @print_logo = static_bucket.link('logos/ABC.long.birmingham.1000.png')
    @wheel_logo = static_bucket.link('flags/PNG/WHEEL.thumb.png')
    @dca_award = static_bucket.link('logos/DCA_web_2016.png')
  end

  def prerender_for_layout
    @nav_links = render_to_string partial: 'application/nav_links'
    @copyright = render_to_string partial: 'application/copyright'
    @wheel_img = view_context.image_tag(@wheel_logo) if @wheel_logo.present?

    return unless current_user&.show_admin_menu?
    @admin_menu = render_to_string partial: 'application/admin_menu'
  end

  def meta_tags
    page_title

    @site_description = <<~DESCRIPTION
      Are you a power or sail boat enthusiast in the Birmingham, MI area?
      Do you know the names of the knots you use?
      Join the Birmingham chapter of the United States Power Squadrons®.
    DESCRIPTION

    @site_keywords = <<~KEYWORDS
      America's Boating Club®, America's Boating Club, birminghampowersquadron.org, Power Squadron, bpsd9.org, Michigan,
      Boating Safety, D9, District 9, fun boating, boating, Birmingham, boater, water, recreation,
      recreational, safety, vessels, education, boating classes, join, weather, sail, sailing,
      powerboats, sailboats, marine, maritime, nautical, navigation, courses, classes,
      Birmingham Power Squadron, Power Squadron vsc, Power Squadron Vessel Exams, USPS,
      Power Squadron, United States Power Squadrons, USPS, Safe Boating, VSC, Vessel Exams,
      Vessel Safety Checks, vessel safety
    KEYWORDS
  end

  def page_title(title = nil)
    title = "#{title} | " if title.present?
    @title = "#{title}America's Boating Club – Birmingham Squadron"
  end

  def markdown_views?
    defined?(MARKDOWN_EDITABLE_VIEWS)
  end
end
