class Event < ApplicationRecord
  belongs_to :event_type
  has_many   :course_topics,   foreign_key: :course_id
  has_many   :course_includes, foreign_key: :course_id
  belongs_to :prereq, class_name: "EventType", optional: true

  before_validation { self.map_link = "http://#{self.map_link}" unless self.map_link.blank? || self.map_link.match(/https?\:\/\//) }

  has_attached_file :flyer,
    default_url: nil,
    storage: :s3,
    s3_region: "us-east-2",
    path: "#{Rails.env}/event_flyers/:id/:filename",
    s3_permissions: :private,
    s3_credentials: {bucket: "bps-files", access_key_id: ENV["S3_ACCESS_KEY"], secret_access_key: ENV["S3_SECRET"]}

  validates_attachment_content_type :flyer, content_type: /\A(image\/(jpe?g|png|gif))|(application\/pdf)\Z/
  
  scope :current, ->(category) do
    includes(:event_type).where("expires_at > ?", Time.now).find_all { |e| e.event_type.in? EventType.send(category) }
  end

  def is_a_course?
    event_type.event_category_id.in? EventType.course_category_ids
  end

  def get_flyer
    f = if is_a_course?
      flyer_file_name.blank? ? get_book_cover : flyer&.s3_object
    elsif flyer_file_name.present?
      flyer.s3_object
    end

    BpsS3::CloudFront.link(bucket: :files, key: f&.key)
  end

  def formatted_cost
    "<b>Cost:</b> $#{cost}".html_safe and return if member_cost.blank?
    "<b>Members:</b> $#{member_cost}, <b>Non-members:</b> $#{cost}".html_safe
  end

  def register_user(user)
    Registration.create(user: user, event: self)
  end

  private
  def get_book_cover
    cover = nil
    [:courses, :seminars].each do |type|
      cover = BpsS3.get_object(bucket: :files, key: "book_covers/#{type.to_s}/#{event_type.title}.jpg") and break if event_type.event_category_id.in?(EventType.course_category_ids)
    end
    cover if cover.exists?
  end
end
