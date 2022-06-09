# frozen_string_literal: true

class UpdateGLYCMembers
  def initialize(pdf)
    @pdf = pdf.respond_to?(:tempfile) ? pdf.tempfile : pdf
  end

  def update
    scan_for_emails
    update_members
  end

private

  def reader
    @reader ||= PDF::Reader.new(@pdf)
  end

  def scan_for_emails
    @all_emails = []

    reader.pages.each do |page|
      @all_emails += page.text.scan(/\s?([\w_\-.]+@[\w_\-.]+)\s?/)
    end

    @all_emails.flatten!
  end

  def update_members
    GLYCMember.where.not(email: @all_emails).destroy_all

    new_emails = @all_emails.reject { |e| e.in? GLYCMember.all.pluck(:email) }
    GLYCMember.create(new_emails.map { |e| { email: e } })
  end
end
