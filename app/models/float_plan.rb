# frozen_string_literal: true

class FloatPlan < ApplicationRecord
  include FloatPlan::Formatting

  belongs_to :user, optional: true
  has_many :float_plan_onboards
  accepts_nested_attributes_for :float_plan_onboards

  validates :float_plan_onboards, presence: true

  after_create { generate_pdf }

  has_attached_file(
    :pdf,
    paperclip_defaults(:files).merge(path: 'float_plans/:id.pdf')
  )

  validates_attachment_content_type(:pdf, content_type: %r{\Aapplication/pdf\z})

  alias onboard :float_plan_onboards

  def generate_pdf
    update!(pdf: BPS::PDF::FloatPlan.for(self))
  end

  def link
    BPS::S3.new(:floatplans).link("#{id}.pdf")
  end

  def invalidate!
    BPS::Invalidation.submit(:files, "/float_plans/#{id}.pdf")
  end
end
