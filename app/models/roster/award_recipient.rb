class Roster::AwardRecipient < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :additional_user, optional: true, class_name: 'User'

  has_attached_file(
    :photo,
    paperclip_defaults(:files).merge(
      path: 'award_recipients/:id/:style/:filename',
      styles: { medium: '500x500', thumb: '200x200' }
    )
  )

  validates_attachment_content_type :photo, content_type: %r{\Aimage/}
  validate :user_or_name
  validates :year, presence: true

  scope :for, ->(award_name) { where(award_name: award_name) }

  def self.current(name = nil)
    return order(:year).for(name).last if name.present?

    order(:year).group_by(&:award_name).values.map(&:last)
  end

  def self.past(name = nil)
    list = name.present? ? where(award_name: name) : all
    list.to_a - current
  end

  def display_name
    return name unless user_id.present?
    return user&.simple_name unless additional_user.present?
    "#{user&.simple_name} and #{additional_user&.simple_name}"
  end

  def display_year
    year.strftime('%Y')
  end

  def user_or_name
    return true if user.present?
    return true if name.present?
    errors.add(:base, 'Must have a user or name')
  end
end
