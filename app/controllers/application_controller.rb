class ApplicationController < ActionController::Base
  force_ssl if: :ssl_configured?
  protect_from_forgery with: :exception

  include BucketHelpers
  helper_method :static_bucket, :files_bucket, :bilge_bucket, :photos_bucket

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :pick_header_image
  before_action :meta_tags
  before_action :set_paper_trail_whodunnit
  before_action :time_formats

  after_action { flash.discard if request.xhr? }

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

  def render_markdown
    render layout: 'application', inline: render_markdown_raw(name: action_name)
  end

  def render_markdown_raw(name: nil, markdown: nil)
    unless name.present? || markdown.present?
      raise ArgumentError, 'Must provide name or markdown.'
    end

    @page_markdown = markdown

    preload_markdown(name)
    generate_markdown_div
    parse_markdown_div
  end

  def preload_markdown(name)
    @page_markdown ||= StaticPage.find_by(name: name)&.markdown

    @burgee_html = center_html do
      USPSFlags::Burgees.new { |b| b.squadron = :birmingham }.svg
    end

    @education_menu = view_context.render(
      'application/education_menu',
      active: { courses: false, seminars: false }
    )
  end

  def generate_markdown_div
    @markdown_div = '<div class="markdown">'
    @markdown_div << redcarpet.render(@page_markdown.to_s.gsub(/(#+)/, '#\1'))
    @markdown_div << '</div>'

    @markdown_div
  end

  def redcarpet
    Redcarpet::Markdown.new(
      TargetBlankRenderer,
      autolink: true,
      images: true,
      tables: true,
      no_intra_emphasis: true,
      strikethrough: true,
      superscript: true,
      underline: true
    )
  end

  def parse_markdown_div
    @markdown_div
      .gsub('<p>@', '<p class="center">')
      .gsub(%r{<p>%burgee</p>}, @burgee_html)
      .gsub(%r{<p>%education</p>}, @education_menu)
      .gsub(%r{(.*?)%static_file/(.*?)/(.*?)/(.*?)$}) { $1 + markdown_static_link($2, title: $3) + $4 }
      .gsub(%r{(.*?)%file/(\d+)/(.*?)/(.*?)$}) { $1 + markdown_file_link($2, title: $3) + $4 }
      .gsub(%r{(.*?)%image/(\d+)/(.*?)$}) { $1 + markdown_image($2) + $3 }
      .gsub('&reg;', '<sup>&reg;</sup>')
      .gsub('<ul>', '<ul class="md">')
      .gsub(%r{(.*?)%fa/(.*?)/(.*?)$}) { $1 + view_context.fa_icon($2) + $3 }
      .gsub(%r{href='(.+@.+\..+)'}) { "href='mailto:#{$1}'" }
  end

  def center_html
    '<div class="center">' + yield + '</div>'
  end

  def pick_header_image
    @header_image = files_bucket.link(key: HeaderImage.all&.map(&:file)&.sample&.path)
    @header_logo = static_bucket.link(key: 'logos/ABC.tr.300.png')
    @print_logo = static_bucket.link(key: 'logos/ABC.long.birmingham.1000.png')
    @wheel_logo = static_bucket.link(key: 'flags/PNG/WHEEL.thumb.png')
    @dca_award = static_bucket.link(key: 'logos/DCA_web_2016.png')
  end

  def markdown_static_link(id, title: '')
    key = get_uploaded_file_name(id)
    link_title = title || key
    link_path = static_bucket.link(key: "general/#{key}")
    view_context.link_to(link_path, target: :_blank) do
      view_context.fa_icon('cloud-download') + link_title
    end
  end

  def markdown_file_link(id, title: '')
    key = get_uploaded_file_name(id)
    link_title = title || key
    link_path = files_bucket.link(key: "uploaded_files/#{key}")
    view_context.link_to(link_path, target: :_blank) do
      view_context.fa_icon('cloud-download') + link_title
    end
  end

  def markdown_image(id)
    key = "uploaded_files/#{get_uploaded_file_name(id)}"
    view_context.image_tag(files_bucket.link(key: key))
  end

  def get_uploaded_file_name(id)
    "#{id}/#{MarkdownFile.find_by(id: id)&.file_file_name}"
  end

  def meta_tags
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
end
