# frozen_string_literal: true

module DateHelper
  ###############
  # ExCom

  def next_excom(date = Date.today)
    month = excom_in_session?(date) ? next_excom_month(date) : 'September'
    date += 1.year if add_year?(month, date)
    excom_date(month, date.strftime('%Y'))
  end

  def excom_in_session?(date = Date.today)
    year = date.strftime('%Y')
    !date.yesterday.between?(excom_date('June', year), excom_date('September', year))
  end

  def excom_date(month = Date.today.strftime('%B'), year = Date.today.strftime('%Y'))
    date = Date.strptime("#{year} #{month}", '%Y %B')
    date += 1.day until date.strftime('%A') == 'Tuesday'
    date += 1.week if date == date.beginning_of_year
    date
  end

  def next_excom_month(date = Date.today)
    next_month(date, excom_date(date.strftime('%B'), date.strftime('%Y')))
  end

  ###############
  # Membership

  def next_membership(date = Date.today)
    month = membership_in_session?(date) ? next_membership_month(date) : 'September'
    date += 1.year if add_year?(month, date)
    membership_date(month, date.strftime('%Y'))
  end

  def membership_in_session?(date = Date.today)
    year = date.strftime('%Y')
    !date.yesterday.between?(membership_date('May', year), membership_date('September', year))
  end

  def membership_date(month = Date.today.strftime('%B'), year = Date.today.strftime('%Y'))
    excom_date(month, year) + 1.week
  end

  def next_membership_month(date = Date.today)
    next_month(date, membership_date(date.strftime('%B'), date.strftime('%Y')))
  end

private

  def next_month(date, meeting_date)
    date += 1.month if date > meeting_date
    date.strftime('%B')
  end

  def add_year?(month, date)
    month == 'January' && date.strftime('%B') == 'December'
  end
end
