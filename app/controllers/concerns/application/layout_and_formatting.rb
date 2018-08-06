# frozen_string_literal: true

module Application::LayoutAndFormatting
  private

  def main_layout
    return 'application_new' if ENV['NEW_HEADER'] == 'enabled'
    return 'application_new' if current_user&.new_layout
    'application_old'
  end

  def load_layout_images
    pick_header_image
    @header_logo = static_bucket.link('logos/ABC.tr.300.png')
    @print_logo = static_bucket.link('logos/ABC.long.birmingham.1000.png')
    @wheel_logo = static_bucket.link('flags/PNG/WHEEL.thumb.png')
    @dca_award = static_bucket.link('logos/DCA_web_2016.png')
  end

  def pick_header_image
    header = if new_header_params[:header].present?
               HeaderImage.find_by(id: new_header_params[:header])&.file
             else
               HeaderImage.random
             end

    @header_image = files_bucket.link(header&.path(:desktop))
  end

  def new_header_params
    params.permit(:header)
  end
end
