# frozen_string_literal: true

class User
  module BOC
    extend ActiveSupport::Concern

    def boc(endorsements: true)
      return boc_level unless endorsements && boc_endorsements.present?

      "#{boc_level} (#{boc_endorsements.join(', ')})"
    end

    def boc_display
      return nil if boc.blank?

      "-#{boc(endorsements: false)}"
    end

  private

    def boc_keys
      @boc_keys ||= course_completions.where(
        course_key: %i[
          BOC_IN BOC_CN BOC_ACN BOC_ON BOC_SA BOC_PAD BOC_IW BOC_CAN BOC_MEX
        ]
      ).map { |c| c.course_key.to_sym }
    end

    def boc_level
      return 'ON'  if boc_keys.include?(:BOC_ON)
      return 'ACN' if boc_keys.include?(:BOC_ACN)
      return 'CN'  if boc_keys.include?(:BOC_CN)
      return 'IN'  if boc_keys.include?(:BOC_IN)
    end

    def boc_endorsements
      boc_keys.reject { |k| k.in?(%i[BOC_ON BOC_ACN BOC_CN BOC_IN]) }.map do |key|
        key.to_s.gsub('BOC_', '').to_sym
      end
    end
  end
end
