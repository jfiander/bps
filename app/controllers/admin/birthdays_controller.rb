# frozen_string_literal: true

module Admin
  class BirthdaysController < ApplicationController
    secure!(:admin)

    def month
      @month = clean_params[:month].to_i
      @birthdays = sorted_users
      render(:list)
    end

    def current
      @month = Date.today.strftime('%m').to_i
      @birthdays = sorted_users
      render(:list)
    end

  private

    def clean_params
      params.permit(:month)
    end

    def users_for_month
      User.where("#{month_query} = '?'", @month).map do |u|
        { name: u.full_name, birthday: u.birthday }
      end
    end

    def sorted_users
      users_for_month.sort do |a, b|
        a[:birthday].strftime('%d').to_i <=> b[:birthday].strftime('%d').to_i
      end
    end

    def month_query
      ENV['ASSET_ENVIRONMENT'] == 'development' ? 'strftime("%m", birthday)' : 'MONTH(birthday)'
    end
  end
end
