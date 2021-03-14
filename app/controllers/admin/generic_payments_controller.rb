# frozen_string_literal: true

module Admin
  class GenericPaymentsController < ApplicationController
    secure!(:admin, strict: true)

    def index
      @generic_payments = GenericPayment.all
    end

  end
end
