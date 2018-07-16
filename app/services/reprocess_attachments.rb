# frozen_string_literal: true

class ReprocessAttachments
  def self.for(*configs)
    # configs = [
    #   [HeaderImage, :file],
    #   [Location, :picture],
    #   [MarkdownFile, :file],
    #   [Photo, :photo_file]
    # ]
    configs.each do |klass, attachment|
      klass.all.each { |object| reprocess(object, attachment) }
    end
  end

  def self.reprocess(object, attachment)
    object.send(attachment).reprocess!
  rescue StandardError
    object.destroy
    object.send("#{attachment}=", nil)
    object.save
  end
end
