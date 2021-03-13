# frozen_string_literal: true

class NominationsMailerPreview < ApplicationMailerPreview
  def nomination_for_moose_milk
    NominationsMailer.nomination(
      user, 'Bill Booth Moose Milk', 'John Q Public', 'How they helped', 'Executive Committee'
    )
  end

  def nomination_for_education
    NominationsMailer.nomination(
      user, 'Education', 'John Q Public', 'Details of education', 'SEO'
    )
  end

  def nomination_for_outstanding_service
    NominationsMailer.nomination(
      user, 'Outstanding Service', 'John Q Public', 'Description of service', 'Commander'
    )
  end
end
