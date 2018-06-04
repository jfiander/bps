# frozen_string_literal: true

module DateHelper
  def next_excom(time = Time.now)
    month = excom_in_session?(time) ? 'the month' : 'September'
    excom_date(month)
  end

  def excom_in_session?(time = Time.now)
    !time.between?(excom_date('June'), excom_date('September'))
  end

  def excom_date(month)
    Chronic.parse("first Tuesday of #{month}")
  end
end
