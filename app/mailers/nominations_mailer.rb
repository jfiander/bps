# frozen_string_literal: true

class NominationsMailer < ApplicationMailer
  def nomination(nominator, award, nominee, target)
    @nominator = nominator
    @award = award
    @nominee = nominee # Simple string, not a user object
    @target = target
    @to_list = to_list

    mail(to: @to_list, subject: 'Award nomination submitted')
  end

private

  def to_list
    case @target
    when 'SEO'
      ['seo@bpsd9.org']
    when 'Commander'
      ['commander@bpsd9.org']
    when 'Executive Committee'
      ['excom@bpsd9.org']
    end
  end
end
