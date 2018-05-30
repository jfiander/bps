class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action { require_permission(:admin, strict: true) }

  def s3
    @link_keys = links.keys
    @r = clean_params[:r]
    @link = links[@r] if @r.in?(links.keys)
  end

  private

  def clean_params
    params.permit(:r, :t)
  end

  def time
    @t = clean_params[:t].present? ? clean_params[:t].to_i : 1.week
    Time.now + @t
  end

  def links
    {
      'abc' => seo_link('Courses/ABC3-2015.zip'),
      'abc-8hr' => seo_link('Courses/ABC3-2015-8hr.zip')
    }
  end

  def seo_link(key)
    BpsS3.new(:seo).link(key, time: time)
  end
end
