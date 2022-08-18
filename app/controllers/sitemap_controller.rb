# frozen_string_literal: true

class SitemapController < ApplicationController
  layout false

  skip_before_action :load_layout_images

  def index
    @pages = pages
    @priorities = priorities
    @frequencies = frequeincies
    @base_url = "http://#{request.host_with_port}/"

    respond_to do |format|
      format.xml
    end
  end

  def robots
    render request.host.match?(/bpsd9\.org/) ? 'robots_allow' : 'robots_disallow'
  end

private

  def pages
    [''] + %w[
      about join requirements vsc education calendar civic
      history links bridge newsletter store photos courses courses/catalog
      seminars seminars/catalog events
    ]
  end

  def priorities
    {
      '' => 1.0,
      'education' => 0.8,
      'courses' => 0.7,
      'seminars' => 0.7,
      'courses/catalog' => 0.6,
      'seminars/catalog' => 0.6,
      'events' => 0.6
    }
  end

  def frequeincies
    {
      'courses' => 'monthly',
      'seminars' => 'monthly',
      'events' => 'monthly',
      'newsletter' => 'monthly',
      'bridge' => 'yearly',
      'courses/catalog' => 'yearly',
      'seminars/catalog' => 'yearly'
    }
  end
end
