# frozen_string_literal: true

module Application::LayoutAndFormatting
  private

  def main_layout
    return 'application_new' if ENV['NEW_HEADER'] == 'enabled'
    return 'application_new' if current_user&.new_layout
    'application_old'
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
end
