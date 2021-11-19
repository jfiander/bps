# frozen_string_literal: true

module Admin
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
      {
        orientation: 'Long', type: 'PNG', size: 1000, background: 'Transparent', text: 'Birmingham'
      }
    end

    def validate_logo
      logo_params[:orientation].in?(%w[Short Long]) &&
        logo_params[:type].in?(%w[PNG SVG]) &&
        logo_params[:background].in?(%w[Transparent White]) &&
        logo_params[:text].in?(%w[Birmingham Burgee Slogan Plain])
    end

    def validate_size
      (logo_params[:size].to_i.positive? && !oversize_logo) || logo_params[:size] == 'Full'
    end

    def oversize_logo
      logo_params[:size].to_i > max_size
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
        @logo_params[:size] = max_size
      else
        logo_params[:size] == 'Full' ? 'Full' : logo_params[:size].to_i.floor(-2)
      end
    end

    def max_size
      logo_params[:orientation] == 'Long' ? 6500 : 600
    end

    def text
      @logo_params[:text] = logo_params[:text]
    end

    def png_key
      File.join('png', logo_params[:orientation], background, text, "#{size}.png").downcase
    end

    def svg_key
      File.join('svg', logo_params[:orientation], "#{text}.svg").downcase
    end

    def find_logo
      return invalid_logo unless validate_logo
      return @logo = BPS::S3.new(:static).link(logo_key) if BPS::S3.new(:static).has?(logo_key)

      attempt_to_generate
    end

    def attempt_to_generate
      return no_svg_available if logo_params[:type] == 'SVG'
      return invalid_logo unless logo_params[:size].to_i.positive?

      upload_logo(generate_logo)
      @logo = BPS::S3.new(:static).link(logo_key)
    end

    def generate_logo
      time = Time.now.to_i
      svg = BPS::S3.new(:static).download("logos/ABC/#{svg_key}")
      generate_png(svg, time, background)

      USPSFlags::Helpers.resize_png(
        "#{Rails.root}/tmp/run/logo-#{time}.png",
        outfile: "#{Rails.root}/tmp/run/logo-#{time}_sized.png", size: size
      )

      "#{Rails.root}/tmp/run/logo-#{time}_sized.png"
    end

    def generate_png(svg, time, background)
      USPSFlags::Generate.png(
        svg,
        outfile: "#{Rails.root}/tmp/run/logo-#{time}.png",
        background: background == 'white' ? '#FFFFFF' : 'none'
      )
    end

    def upload_logo(file)
      BPS::S3.new(:static).upload(file: file, key: logo_key)
    end
  end
end
