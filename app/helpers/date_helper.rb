# frozen_string_literal: true

module DateHelper
  def next_excom
    month = excom_in_session? ? 'the month' : 'September'
    excom_date(month)
  end

  def excom_in_session?
    !Time.now.between?(excom_date('June'), excom_date('September'))
  end

  def excom_date(month)
    Chronic.parse("first Tuesday of #{month}")
  end
end
