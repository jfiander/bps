# frozen_string_literal: true

class FlagsController < ApplicationController
  before_action :bucket, only: %i[flags national signals]

  title!('Flags')

  def flags
    @show_birmingham = true
    render(:flags, layout: 'application')
  end

  def national
    @show_birmingham = false
    @generic_logo = @bucket.link('logos/ABC/png/long/tr/slogan/1000.png')
    render(:flags, layout: 'flags')
  end

  def tridents
    svg = USPSFlags::Generate.spec(
      fly: fly, unit: unit, scale: scale, scaled_border: params[:border].present?
    )

    respond_to do |format|
      format.svg { render inline: svg }
    end
  end

  def intersections
    fly = clean_params[:fly].present? ? Rational(clean_params[:fly]) : 2048

    svg = USPSFlags::Generate.intersection_spec(
      fly: fly, scale: scale, scaled_border: params[:border].present?
    )

    respond_to do |format|
      format.svg { render inline: svg }
    end
  end

  def signals
    @letters = %w[
      alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima mike november oscar
      papa quebec romeo sierra tango uniform victor whiskey xray yankee zulu
    ].map { |name| Signal.new(name, name[0], :letters) }

    @numerals = [
      [:zero, 0], [:one, 1], [:two, 2], [:three, 3], [:four, 4],
      [:five, 5], [:six, 6], [:seven, 7], [:eight, 8], [:nine, 9]
    ].map { |name, short| Signal.new(name, short, :numbers) }

    @codes = %i[repeat_1 repeat_2 repeat_3 code].map { |name| Signal.new(name, nil, :codes) }

    render(:signals, layout: 'application')
  end
  Signal = Struct.new(:name, :short, :dir)

private

  def clean_params
    params.permit(:flag_type, :format, :fly, :unit, :scale, :size, :border)
  end

  def bucket
    @bucket = BPS::S3.new(:static)
  end

  def fly
    clean_params[:fly].present? ? Rational(clean_params[:fly]) : 24
  end

  def unit
    return ' ' if clean_params[:unit] == 'none'
    return 'in' if clean_params[:unit].blank?

    clean_params[:unit]
  end

  def scale
    return clean_params[:scale].to_i if int_scale?
    return clean_params[:scale].to_f if float_scale?
  end

  def int_scale?
    clean_params[:scale].present? && clean_params[:scale].to_i.positive?
  end

  def float_scale?
    clean_params[:scale].present? && clean_params[:scale].to_f.positive?
  end

  def cache_file(key); end
end
