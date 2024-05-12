# frozen_string_literal: true

class VerificationController < ApplicationController
  layout false

  skip_before_action :load_layout_images

  def applepay
    data = BPS::S3.new(:static).download('verification/domain-association-file-live')
    send_data(data, filename: 'domain-association-file-live', disposition: :inline)
  end
end
