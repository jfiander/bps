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
      gsub(/(.*?)%file\/(\d+)\/(.*?)\/(.*?)\/(.*?)$/, '\1' + markdown_file_link('\2/\3', title: '\4') + '\5').
      gsub(/(.*?)%image\/(\d+)\/(.*?)\/(.*?)$/, '\1' + markdown_image('\2/\3') + '\4').
      gsub("&reg;", "<sup>&reg;</sup>").
      gsub(/(.*?)%fa\/(.*?)\/(.*?)$/, view_context.fa_icon('\2'))
  end

  def center_html
    "<div class='center'>" + yield + "</div>"
  end

  def pick_header_image
    objects = static_bucket.list(prefix: "headers/")
    keys = objects.map(&:key)
    keys.shift
    @header_image = static_bucket.link(key: keys.sample)
    @header_wheel = open(static_bucket.link(key: "flags/SVG/WHEEL.svg")).read.html_safe
  end

  def markdown_static_link(key, title: "")
    link_title = title || key
    link_path = static_bucket.link(key: "general/#{key}")
    view_context.link_to(link_path, target: :_blank) do
      view_context.fa_icon("cloud-download") + link_title
    end
  end

  def markdown_file_link(key, title: "")
    link_title = title || key
    link_path = files_bucket.link(key: "uploaded_files/#{key}")
    view_context.link_to(link_path, target: :_blank) do
      view_context.fa_icon("cloud-download") + link_title
    end
  end

  def markdown_image(key)
    key = "uploaded_files/#{key}"
    view_context.image_tag(files_bucket.link(key: key))
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

  def officer_flag(office)
    rank = case office
    when "commander"
      "CDR"
    when "executive", "educational", "administrative", "secretary", "treasurer"
      "LTC"
    when "asst_educational", "asst_secretary"
      "1LT"
    end

    open(static_bucket.link(key: "flags/SVG/#{rank}.svg")).read.html_safe
  end
  helper_method :officer_flag

  def spinner_button(form = nil, button_text: "Submit", disable_text: nil)
    disable_text ||= button_text.sub(/e$/, '') + "ing"
    data_hash = { disable_with: (view_context.fa_icon("spinner pulse") + "#{disable_text}...") }
    
    return form.button(button_text, data: data_hash) if form.present?
    view_context.button_tag(button_text, data: data_hash)
  end
  helper_method :spinner_button

  def static_bucket
    ApplicationRecord.buckets[:static]
  end

  def files_bucket
    ApplicationRecord.buckets[:files]
  end

  def bilge_bucket
    ApplicationRecord.buckets[:bilge]
  end
  
  def photos_bucket
    ApplicationRecord.buckets[:photos]
  end
  helper_method :static_bucket, :files_bucket, :bilge_bucket, :photos_bucket
end
