# frozen_string_literal: true

module Members
  module Nominations
    def nominations
      @awards = BpsPdf::Roster::Detailed::CONFIG_TEXT[:awards]
      @description = @awards.delete(:top)
    end

    def nominate
      return redirect_to(nominate_path) if submitted_nominations.blank?

      nomination_mails

      redirect_to(nominate_path, success: success_notice)
    end

  private

    def nominations_params
      params.permit(nominations: {}, descriptions: {})
    end

    def submitted_nominations
      nominations_params['nominations'].reject { |_, v| v.blank? }
    end

    def submitted_descriptions
      nominations_params['descriptions']
    end

    def award_target(award_name)
      {
        'Bill Booth Moose Milk' => 'Executive Committee',
        'Jim McMicking Outstanding Instructor' => 'Executive Committee',
        'Master Mariner' => 'Executive Committee',
        'Outstanding Service' => 'Commander',
        'High Flyer' => 'Commander',
        'Education' => 'SEO'
      }[award_name]
    end

    def success_notice
      if nominations_params.to_h.keys.size > 1
        'Your nominations have been successfully submitted.'
      else
        'Your nomination has been successfully submitted.'
      end
    end
  end

  def nomination_mails
    submitted_nominations.each do |award, nominee|
      NominationsMailer.nomination(
        current_user, award, nominee, submitted_descriptions[award], award_target(award)
      ).deliver
    end
  end
end
