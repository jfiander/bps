class SitemapController < ApplicationController
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
end
