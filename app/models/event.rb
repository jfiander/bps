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
  
  scope :current, ->(category) do
    event_category_id = EventCategory.where(title: category.to_s)
    where("expires_at > ?", Time.now).where(event_category: event_category_id)
  end

  def is_a_course?
    event_category&.title.in? ["advanced_grade", "elective"]
  end
end
