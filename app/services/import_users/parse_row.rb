# frozen_string_literal: true

module ImportUsers
  # Individual CSV row parser for user importing
  class ParseRow
    def initialize(row)
      @row = row
      @changes = nil
    end

    def call
      @user = User.unscoped.find_by(certificate: @row['Certificate'])
      @user.present? ? update_user : new_user
    end

  private

    def new_user
      [User.create!(ImportUsers::Hash.new(@row).new_user), :created]
    end

    def update_user
      @user.assign_attributes(ImportUsers::Hash.new(@row).update_user)
      if @user.changed.present?
        changes = @user.changes
        @user.save!
      end
      [@user, changes]
    end
  end
end
