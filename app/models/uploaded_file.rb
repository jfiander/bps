# frozen_string_literal: true

class UploadedFile < ApplicationRecord
  self.abstract_class = true

  has_attached_file(
    :file,
    paperclip_defaults(:files).merge(path: 'uploaded/:class/:id/:filename')
  )

  validates_attachment_content_type :file, content_type: %r{\A(image/(jpe?g|png|gif))|(application/pdf)\z}
  validates :file, presence: true
end
