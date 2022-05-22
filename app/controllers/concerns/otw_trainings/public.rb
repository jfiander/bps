# frozen_string_literal: true

module OTWTrainings
  module Public
    def public; end

    def public_request
      OTWMailer.jumpstart(otw_public_params).deliver
    end

  private

    def otw_public_params
      params.permit(:name, :email, :phone, :details, :availability)
    end
  end
end
