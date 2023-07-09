# frozen_string_literal: true

module DmarcReportsHelper
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
