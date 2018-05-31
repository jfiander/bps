# frozen_string_literal: true

class MarkdownFile < ApplicationRecord
  has_attached_file(
    :file,
    paperclip_defaults(:files).merge(path: 'uploaded_files/:id/:filename')
  )

  validates_attachment_content_type :file, content_type: %r{\A(image/(jpe?g|png|gif))|(application/pdf)\z}
  validates :file, presence: true
end
