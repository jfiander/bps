# frozen_string_literal: true

module Concerns::FloatPlan::Formatting
  extend ActiveSupport::Concern

  def fuel
    if fuel_capacity.present?
      "#{fuel_capacity} gallons"
    else
      'n/a'
    end
  end

  def engines
    if engines?
      [
        number_of_engines,
        [engine_types, hp].reject(&:blank?).join(' – ')
      ].join(' ')
    else
      'n/a'
    end
  end

  def boat_type_display
    "#{boat_type}#{subtype.present? ? " (#{subtype})" : ''}"
  end

  def radio_bands
    [
      flag(radio_vhf, 'VHF'),
      flag(radio_ssb, 'SSB'),
      flag(radio_cb, 'CB'),
      flag(radio_cell_phone, 'Cell Phone')
    ].compact.join(' / ')
  end

  def epirb_freqs
    [
      flag(epirb_16, 'Ch 16'),
      flag(epirb_1215, '121.5 MHz'),
      flag(epirb_406, '406 MHz')
    ].compact.join(' / ')
  end

private

  def engines?
    number_of_engines.present? ||
      engine_type_1.present? ||
      engine_type_2.present? ||
      horse_power.present?
  end

  def engine_types
    engine_types = [engine_type_1, engine_type_2].reject(&:blank?).join(' / ')
    engine_types.present? ? "(#{engine_types})" : nil
  end

  def hp
    horse_power.present? ? "#{horse_power} HP" : nil
  end

  def flag(bool, string)
    bool ? string : nil
  end
end
