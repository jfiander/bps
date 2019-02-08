# frozen_string_literal: true

class Admin::LinksController < ApplicationController
  secure!(:admin, strict: true)

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
      'abc' => seo_link('Courses/ABC3-16-hour.zip'),
      'abc-8hr' => seo_link('Courses/ABC3-8-hour.zip'),
      'Sextant Lease (fillable)' => seo_link('Sextant/fillable/SEXTANT_LEASE_AGREEMENT.pdf'),
      'Sextant Lease (flat)' => seo_link('Sextant/SEXTANT_LEASE_AGREEMENT.pdf')
    }
  end

  def seo_link(key)
    BpsS3.new(:seo).link(key, time: time)
  end
end
