# frozen_string_literal: true

module Application::LayoutAndFormatting
  private

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
    @nav_links = render_to_string partial: 'application/navigation/links'
    @copyright = render_to_string partial: 'application/copyright'
    if @wheel_logo.present?
      @wheel_img = view_context.image_tag(@wheel_logo, alt: 'USPS Ensign Wheel')
    end

    return unless current_user&.show_admin_menu?
    @admin_menu = {
      desktop: render_to_string(partial: 'application/navigation/admin/desktop'),
      mobile: render_to_string(partial: 'application/navigation/admin/mobile')
    }
  end
end
