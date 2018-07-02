# frozen_string_literal: true

module DateHelper
  def next_excom(date = Date.today)
    month = excom_in_session?(date) ? next_excom_month(date) : 'September'
    excom_date(month)
  end

  def excom_in_session?(date = Date.today)
    !date.between?(excom_date('June'), excom_date('September'))
  end

  def excom_date(month = Date.today.strftime('%B'))
    date = Date.strptime("#{Date.today.year} #{month}", '%Y %B')
    date += 1.day until date.strftime('%A') == 'Tuesday'
    date
  end

  def next_excom_month(date = Date.today)
    date += 1.month if date > excom_date(date.strftime('%B'))
    date.strftime('%B')
  end

  def next_excom_over_30_days?(date = Date.today)
    (next_excom(date) - date).to_i > 40
  end
end
