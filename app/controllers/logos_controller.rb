# frozen_string_literal: true

class LogosController < ApplicationController
  secure!(:admin)

  def logo
    @logo_params = default_params
    return unless logo_params.present?

    @logo_params = logo_params
    find_logo
  end

private

  def logo_params
    params.permit(:orientation, :type, :size, :background, :text)
  end

  def default_params
    { orientation: 'Long', type: 'PNG', size: 1000, background: 'Transparent', text: 'Birmingham' }
  end

  def validate_logo
    logo_params[:orientation].in?(%w[Short Long]) &&
      logo_params[:type].in?(%w[PNG SVG]) &&
      logo_params[:background].in?(%w[Transparent White]) &&
      logo_params[:text].in?(%w[Birmingham Slogan Simple])
  end

  def validate_size
    (logo_params[:size].to_i > 0 && !oversize_logo) || logo_params[:size] == 'Full'
  end

  def oversize_logo
    (logo_params[:orientation] == 'Long' && logo_params[:size].to_i > 6600) ||
      (logo_params[:orientation] == 'Short' && logo_params[:size].to_i > 600)
  end

  def invalid_logo
    flash[:alert] = 'Invalid logo configuration.'
  end

  def no_svg_available
    flash[:alert] = 'That SVG logo is not available.'
  end

  def logo_key
    key = png_key if logo_params[:type] == 'PNG'
    key = svg_key if logo_params[:type] == 'SVG'

    "logos/ABC/#{key}"
  end

  def background
    logo_params[:background] == 'Transparent' ? 'tr' : 'white'
  end

  def size
    if oversize_logo
      @logo_params[:size] = logo_params[:orientation] == 'Long' ? 6600 : 600
    else
      logo_params[:size] == 'Full' ? 'Full' : logo_params[:size].to_i.floor(-2)
    end
  end

  def text
    if logo_params[:orientation] == 'Short' && logo_params[:text] == 'Birmingham'
      @logo_params[:text] = 'Slogan'
      'Slogan'
    else
      logo_params[:text]
    end
  end

  def png_key
    (File.join('png', logo_params[:orientation], background, text, size.to_s) + '.png').downcase
  end

  def svg_key
    (File.join('svg', logo_params[:orientation], text) + '.svg').downcase
  end

  def find_logo
    return invalid_logo unless validate_logo
    return @logo = static_bucket.link(logo_key) if static_bucket.has?(logo_key)

    attempt_to_generate
  end

  def attempt_to_generate
    return no_svg_available if logo_params[:type] == 'SVG'
    return invalid_logo unless logo_params[:size].to_i > 0

    upload_logo(generate_logo)
    @logo = static_bucket.link(logo_key)
  end

  def generate_logo
    time = Time.now.to_i
    svg = static_bucket.download("logos/ABC/#{svg_key}")
    USPSFlags::Generate.png(svg, outfile: "#{Rails.root}/tmp/run/logo-#{time}.png")
    USPSFlags::Helpers.resize_png(
      "#{Rails.root}/tmp/run/logo-#{time}.png",
      outfile: "#{Rails.root}/tmp/run/logo-#{time}_sized.png", size: size
    )

    "#{Rails.root}/tmp/run/logo-#{time}_sized.png"
  end

  def upload_logo(file)
    static_bucket.upload(file: file, key: logo_key)
  end
end
