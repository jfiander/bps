# frozen_string_literal: true

module Members
  module Nominations
    include DateHelper

    def nominations
      @awards = BPS::PDF::Roster::Detailed::CONFIG_TEXT[:awards].dup
      @description = @awards.delete(:top)
      due_date
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
      nominations_params['nominations'].compact_blank
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

    def due_date
      @due_date = excom_date('November', Time.zone.today.year) + 12.hours
      return @due_date unless Time.zone.now > @due_date

      @due_date = excom_date('November', Time.zone.today.year + 1) + 12.hours
    end

    def nomination_mails
      submitted_nominations.each do |award, nominee|
        target = award_target(award)

        NominationsMailer.nomination(
          current_user, award, nominee, submitted_descriptions[award], target
        ).deliver

        slack_notification(current_user, award, nominee) if target == 'Executive Committee'
      end
    end

    def slack_notification(current_user, award, nominee)
      SlackNotification.new(
        channel: :excom, type: :info, title: 'Award Nomination Submitted',
        fallback: 'Someone has submitted a nomination for an ExCom award.',
        fields: {
          'Nominator' => current_user.full_name,
          'Award' => award,
          'Nominee' => nominee
        }
      ).notify!
    end
  end
end
