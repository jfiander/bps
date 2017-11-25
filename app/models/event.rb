class Event < ApplicationRecord
  belongs_to :event_type
  belongs_to :event_category
  has_many   :course_topics
  has_many   :course_includes
  has_one    :prereq, class_name: "Event"

  before_validation { self.event_category = self.event_type.event_category }

  has_attached_file :flyer,
    default_url: nil,
    storage: :s3,
    s3_region: "us-east-2",
    path: "#{Rails.env}/event_flyers/:id/:filename",
    s3_permissions: :private,
    s3_credentials: {bucket: "bps-files", access_key_id: ENV["S3_ACCESS_KEY"], secret_access_key: ENV["S3_SECRET"]}

  validates_attachment_content_type :flyer, content_type: /\A(image\/(jpe?g|png|gif))|(application\/pdf)\Z/
  
  scope :current, ->(category) do
    event_category_id = EventCategory.where(title: category.to_s)
    where("expires_at > ?", Time.now).where(event_category: event_category_id)
  end

  def is_a_course?
    event_category&.title.in? ["advanced_grade", "elective"]
  end

  def get_flyer
    f = if is_a_course?
      flyer_file_name.blank? ? get_book_cover : flyer&.s3_object
    elsif flyer_file_name.present?
      flyer.s3_object
    end

    f&.presigned_url(:get, expires_in: 5.minutes)
  end

  private
  def get_book_cover
    [:courses, :seminars].each do |type|
      return BpsS3.get_object(bucket: :files, key: "book_covers/#{type.to_s}/#{event_type.title}.png") if event_category_id.in?(EventCategory.send(type).map(&:id))
    end
  end
end
