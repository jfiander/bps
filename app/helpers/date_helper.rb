module DateHelper
  def next_excom
    month = excom_in_session? ? 'the month' : 'September'
    excom_date(month)
  end

  def excom_in_session?
    !Time.now.between?(excom_date('June'), excom_date('September'))
  end

  def excom_date(month)
    Tickle.parse(
      "the 1st Tuesday of #{month}",
      now: Date.today,
      next_only: true
    )
  end
end
