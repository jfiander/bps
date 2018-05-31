# frozen_string_literal: true

class Photo < ApplicationRecord
  belongs_to :album

  has_attached_fle(
    :photo_file,
    paperclip_defaults(:files).merge(
      path: 'uploaded_files/:id/:filename',
      styles: { medium: '500x500', thumb: '200x200' }
    )
  )

  validates_attachment_content_type :photo_file, content_type: %r{\Aimage/}
  validates :photo_file, presence: true
end
