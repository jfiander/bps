class PublicController < ApplicationController
  before_action :display_admin_menu, if: :current_user_is_admin?

  def index
    #
  end

  def about
    #
  end

  def join
    #
  end

  def vsc
    #
  end

  def education
    #
  end

  def calendar
    #
  end

  def events
    #
  end

  def photos
    #
  end

  def civic
    #
  end

  def bridge
    #
  end

  def history
    #
  end

  def newsletter
    bilges = BpsS3.list(bucket: :bilge)

    @years = bilges.map(&:key).map { |b| b.delete('.pdf').gsub(/\/(s|\d+)/, '') }.uniq

    @bilge_links = bilges.map do |b|
      key = b.key.dup
      issue_date = b.key.delete(".pdf")
      { issue_date => BpsS3.link(bucket: :bilge, key: key) }
    end.reduce({}, :merge)
  end

  def store
    #
  end

  def links
    #
  end

  private
  def display_admin_menu
    @admin_menu = true
  end

  def clean_params
    params.permit()
  end
end
