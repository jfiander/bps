# frozen_string_literal: true

class BirthdaysController < ApplicationController
  secure!(:users)

  def birthdays
    if clean_params[:month].to_i.positive?
      month
    else
      current
    end
    render(:list)
  end

private

  def clean_params
    params.permit(:month)
  end

  def month
    @month = clean_params[:month].to_i
    @birthdays = sorted_users
  end

  def current
    @month = Date.today.strftime('%m').to_i
    @birthdays = sorted_users
  end

  def users_for_month
    User.where("#{month_query} = '?' OR #{month_query} = '0?'", @month, @month).map do |u|
      { name: u.full_name, birthday: u.birthday }
    end
  end

  def sorted_users
    users_for_month.sort do |a, b|
      a[:birthday].strftime('%d').to_i <=> b[:birthday].strftime('%d').to_i
    end
  end

  def month_query
    sqlite = 'strftime("%m", birthday)'
    pg = 'EXTRACT(MONTH FROM birthday)'
    # mysql = 'MONTH(birthday)'
    ENV['ASSET_ENVIRONMENT'] == 'development' ? sqlite : pg
  end
end
