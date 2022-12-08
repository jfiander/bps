# frozen_string_literal: true

class MeritMarksController < ApplicationController
  secure!(:users)

  def index
    today = Date.today
    @year = today.month < 9 ? today.year - 1 : today.year
    boundary = Time.strptime("#{@year}/09/01 00:00 EST", '%Y/%m/%d %H:%M %Z').to_datetime

    @recent_mm_users = User.alphabetized.recent_mm.select { |i| i.last_mm_year >= boundary }
  end
end
