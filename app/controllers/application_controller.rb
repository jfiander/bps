class ApplicationController < ActionController::Base
  force_ssl if: :ssl_configured?
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

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
      gsub(/<p>%education<\/p>/, education_menu)
  end

  def center_html
    "<div class='center'>" + yield + "</div>"
  end
end
