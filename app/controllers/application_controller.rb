# frozen_string_literal: true

class ApplicationController < ActionController::Base
  force_ssl if: :ssl_configured?
  protect_from_forgery with: :exception
  add_flash_types :success, :error

  include Application::Meta
  include Application::LayoutAndFormatting
  include Application::Security
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

  skip_before_action :verify_authenticity_token, only: %i[auto_show auto_hide]

  after_action { flash.discard if request.xhr? }

  ::GIT_INFORMATION ||= GitInfo.new

  def self.render_markdown_views
    before_action :render_markdown, only: MarkdownHelper::VIEWS[controller_name]
    MarkdownHelper::VIEWS[controller_name]&.each { |m| define_method(m) {} }
  end

  def self.title!(title = nil, only: nil, except: nil)
    title = yield if block_given?
    before_action(only: only, except: except) { page_title(title) }
  end

  def self.ajax!(only: nil, except: nil)
    skip_before_action(:prerender_for_layout, only: only, except: except)
  end

  # Overwritten by Events controllers
  def event_type_param
    nil
  end
  helper_method :event_type_param
end
