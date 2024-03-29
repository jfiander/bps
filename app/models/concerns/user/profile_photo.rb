# frozen_string_literal: true

class User
  module ProfilePhoto
    extend ActiveSupport::Concern

    def photo(style: :medium)
      if photo?
        BPS::S3.new(:files).link(profile_photo.s3_object(style).key)
      else
        User.no_photo
      end
    end

    def assign_photo(local_path:)
      attach_photo(File.open(local_path))
      save!
    end

  private

    def photo?
      profile_photo.present? &&
        BPS::S3.new(:files).object(profile_photo.s3_object.key).exists?
    end

    def attach_photo(file)
      attach = Paperclip::Attachment.new(
        'profile_photo',
        self,
        User.attachment_definitions[:profile_photo]
      )

      attach.assign(file)
      attach.save
      file.close
    end
  end
end
