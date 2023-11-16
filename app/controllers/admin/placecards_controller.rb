# frozen_string_literal: true

module Admin
  class PlacecardsController < ::ApplicationController
    secure!(:admin, strict: true)

    title!('Placecards')

    layout(false, only: :create)

    before_action(:prepare_data, only: :create)

    def new; end

    def create; end

  private

    def prepare_data
      csv = CSV.read(params[:csv].path, headers: true)

      @data = csv.sort_by { |person| sort_names(person) }
    end

    def sort_names(person)
      rank_and_name = person['name'].sub(/, \w+/, '')

      name = rank_and_name.split.reject do |chunk|
        %w[Lt Cdr Commodore].include?(chunk) || chunk =~ %r{/}
      end.join(' ')

      parts = name.split
      last = parts.pop
      last = person['sort'] if person.key?('sort') && person['sort'].present?
      first = parts.join(' ')

      [last, first]
    end
  end
end
