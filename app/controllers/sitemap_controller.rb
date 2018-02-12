class SitemapController < ApplicationController
  layout false

  def index
    @pages = [''] + %w[
      about join requirements vsc education calendar civic
      history links bridge newsletter store photos courses courses/catalog
      seminars seminars/catalog events
    ]

    respond_to do |format|
      format.xml
    end
  end

  def robots
    render request.host.match?(/bpsd9\.org/) ? 'robots_allow' : 'robots_disallow'
  end
end
