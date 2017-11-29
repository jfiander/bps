class ApplicationController < ActionController::Base
  force_ssl if: :ssl_configured?
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :pick_header_image
  before_action :meta_tags

  after_action { flash.discard if request.xhr? }

  private
  def ssl_configured?
    Rails.env.production?
  end

  def require_permission(role)
    redirect_to root_path and return unless current_user&.permitted?(role)
    # before_action only: [:method_1, :method_2] { require_permission(:role_name) }
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:profile_photo, :rank, :first_name, :last_name])
  end

  def time_formats
    @long_time_format = "%a %d %b %Y @ %H%M %Z"
    @medium_time_format = "%-m/%-d/%Y @ %H%M"
    @short_time_format = "%-m/%-d @ %H%M"
    @duration_format = "%-kh %Mm"
  end

  def render_markdown
    burgee_html = center_html { USPSFlags::Burgees.new { |b| b.squadron = :birmingham }.svg }
    education_menu = view_context.render "application/education_menu", active: {courses: false, seminars: false}

    render layout: "application", inline: ("<div class='markdown'>" + Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      autolink: true,
      images: true,
      tables: true,
      no_intra_emphasis: true,
      strikethrough: true,
      superscript: true,
      underline: true
    ).render(StaticPage.find_by(name: action_name)&.markdown.to_s.
      gsub(/(#+)/, '#\1')
    ) + "</div>").
      gsub("<p>@", '<p class="center">').
      gsub(/<p>%burgee<\/p>/, burgee_html).
      gsub(/<p>%education<\/p>/, education_menu).
      gsub(/(.*?)%static_file\/(.*?)\/(.*?)\/(.*?)$/, '\1' + markdown_static_link('\2', title: '\3') + '\4').
      gsub(/(.*?)%file\/(.*?)\/(.*?)\/(.*?)$/, '\1' + markdown_file_link('\2', title: '\3') + '\4').
      gsub(/(.*?)%image\/(.*?)\/(.*?)$/, '\1' + markdown_image('\2') + '\3')
  end

  def center_html
    "<div class='center'>" + yield + "</div>"
  end

  def pick_header_image
    objects = BpsS3.list(bucket: :files, prefix: "static/headers/")
    keys = objects.map(&:key)
    keys.shift
    @header_image = BpsS3::CloudFront.link(bucket: :files, key: keys.sample)
  end

  def markdown_static_link(key, title: "")
    link_title = title || key
    link_path = BpsS3::CloudFront.link(bucket: :files, key: "static/general/#{key}")
    view_context.link_to(link_title, link_path)
  end

  def markdown_file_link(key, title: "")
    link_title = title || key
    link_path = BpsS3::CloudFront.link(bucket: :files, key: "#{ENV['ASSET_ENVIRONMENT']}/uploaded_files/#{key}")
    view_context.link_to(link_title, link_path)
  end

  def markdown_image(key)
    key = "#{ENV['ASSET_ENVIRONMENT']}/uploaded_files/#{key}"
    view_context.image_tag(BpsS3::CloudFront.link(bucket: :files, key: key))
  end

  def meta_tags
    @site_description = <<~DESCRIPTION
      Are you a power or sail boat enthusiast in the Birmingham MI area?
      Do you know the names of the knots you use?
      Join the Birmingham chapter of the United States Power Squadron.
    DESCRIPTION

    keywords = <<~KEYWORDS
      America's Boating Club®, birminghampowersquadron.org Power Squadron, bpsd9.org, Michigan,
      Boating Safety, D9, District 9, fun boating, boating, Birmingham, boater, water, recreation,
      recreational, safety, vessels, education, boating classes, join, weather, sail, sailing,
      powerboats, sailboats, marine, maritime, nautical, navigation, courses, classes,
      Birmingham Power Squadron, Power Squadron vsc, Power Squadron Vessel Exams, USPS,
      Power Squadron, United States Power Squadrons, U.S.P.S., Safe Boating, VSC, Vessel Exams,
      Vessel Safety Checks, VSC, America's Boating Club
    KEYWORDS
    @site_keywords = keywords
  end
end
