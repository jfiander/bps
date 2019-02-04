# frozen_string_literal: true

module DateHelper
  def next_excom(date = Date.today)
    month = excom_in_session?(date) ? next_excom_month(date) : 'September'
    excom_date(month, date.strftime('%Y'))
  end

  def excom_in_session?(date = Date.today)
    !date.between?(
      excom_date('June', date.strftime('%Y')), excom_date('September', date.strftime('%Y'))
    )
  end

  def excom_date(month = Date.today.strftime('%B'), year = Date.today.strftime('%Y'))
    date = Date.strptime("#{year} #{month}", '%Y %B')
    date += 1.day until date.strftime('%A') == 'Tuesday'
    date
  end

  def next_excom_month(date = Date.today)
    date += 1.month if date > excom_date(date.strftime('%B'), date.strftime('%Y'))
    date.strftime('%B')
  end

  def next_excom_over_30_days?(date = Date.today)
    (next_excom(date) - date).to_i > 40
  end

  def next_membership(date = Date.today)
    excom = next_excom(date)
    return excom + 1.week unless excom.strftime('%B') == 'June'

    next_excom(date + 1.month) + 1.week
  end
end
