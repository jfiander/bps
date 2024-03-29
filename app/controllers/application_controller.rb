# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :error

  include Application::Meta
  include Application::LayoutAndFormatting
  include Application::Security
  include MarkdownHelper
  include ApplicationHelper
  include Menu::MenuHelper

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_layout_images
  before_action :meta_tags
  before_action :set_paper_trail_whodunnit
  before_bugsnag_notify :bugsnag_format_user

  skip_before_action :verify_authenticity_token, only: %i[auto_show auto_hide]

  after_action { flash.discard if request.xhr? }

  # Handle all requests for PHP files with a status code, instead of letting them raise exceptions
  rescue_from ActionController::UnknownFormat do |e|
    request.format.php? ? render(plain: 'No', status: :bad_request) : raise(e)
  end

  ::GIT_INFORMATION = BPS::GitInfo.new

  def self.render_markdown_views
    before_action :render_markdown, only: MarkdownHelper::VIEWS[controller_name]
    MarkdownHelper::VIEWS[controller_name]&.each { |m| define_method(m) { nil } }
  end

  def self.title!(title = nil, only: nil, except: nil)
    title = yield if block_given?
    before_action(only: only, except: except) { page_title(title) }
  end

  # Overwritten by Events controllers
  def event_type_param
    nil
  end
  helper_method :event_type_param

private

  def bugsnag_format_user(report)
    report.user = {
      id: current_user.id,
      name: current_user.simple_name,
      certificate: current_user.certificate,
      email: current_user.email,
      created_at: current_user.created_at
    }
  end

  def unprocessable!
    render('errors/unprocessable_entity', status: :unprocessable_entity)
  end
end
