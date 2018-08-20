class OTWMailer < ApplicationMailer
  def requested(otw_training_user)
    @otw = otw_training_user.otw_training
    @user = otw_training_user.user
    @to_list = to_list

    mail(to: @to_list, subject: 'On-the-Water training requested')
  end

  def jumpstart(options = {})
    @options = options.symbolize_keys!
    @to_list = to_list

    mail(to: @to_list, subject: 'Jump Start training requested')
  end

  private

  def to_list
    list = ['seo@bpsd9.org', 'aseo@bpsd9.org']

    committees = Committee.get(:educational, 'On-the-Water Training')
    list << committees&.map { |c| c&.user&.email }
  end
end
