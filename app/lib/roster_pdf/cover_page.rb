# frozen_string_literal: true

module RosterPDF::CoverPage
  def cover_page(orientation, include_blank: false)
    @orientation = orientation
    load_logo
    load_burgee

    landscape_back_page if @orientation == :landscape && include_blank
    insert_image 'tmp/run/ABC-B.png', at: [0, cover_config[:logo][:y]], width: cover_config[:logo][:width]
    title
    insert_image 'tmp/run/Burgee.png', at: [25, cover_config[:burgee][:y]], width: cover_config[:burgee][:width]
    timestamp
  end

  private

  def title
    bounding_box([0, cover_config[:title][:y]], width: cover_config[:title][:width], height: 35) do
      text 'Membership Roster', size: cover_config[:title][:size], style: :bold, align: :center
    end
  end

  def timestamp
    bounding_box([0, cover_config[:timestamp][:y]], width: cover_config[:timestamp][:width], height: 35) do
      timestamp = Time.now.strftime(ApplicationController::MEDIUM_TIME_FORMAT)
      text "Generated: #{timestamp}", size: 12, style: :bold, align: :center
    end
  end

  def landscape_back_page
    bounding_box([0, cover_config[:title][:y] - 100], width: cover_config[:title][:width], height: 35) do
      text 'This page left intentionally blank.', size: 14, align: :center
    end
    start_new_page
  end

  def cover_config
    config[:cover][@orientation]
  end
end
