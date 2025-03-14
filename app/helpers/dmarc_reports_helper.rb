# frozen_string_literal: true

module DmarcReportsHelper
  def dmarc_field_icon(dmarc_field)
    case dmarc_field
    when :disposition
      FA::Icon.p('share', style: :duotone, fa: :fw)
    when :dkim
      FA::Icon.p('d', style: :duotone, fa: :fw)
    when :spf
      FA::Icon.p('s', style: :duotone, fa: :fw)
    end
  end

  def disposition_icon(disposition)
    {
      NONE: 'circle-check',
      QUARANTINE: 'folder-xmark',
      REJECT: 'octagon-xmark'
    }[disposition]
  end

  def dmarc_result_icon(result)
    case result
    when 'pass'
      'circle-check'
    else
      'octagon-xmark'
    end
  end
end
