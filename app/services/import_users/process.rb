# frozen_string_literal: true

module ImportUsers
  # Process result proto to apply changes for user importing
  class Process
    def initialize(id, lock: false)
      import_log = ImportLog.find(id)

      @proto = import_log.decode
      @lock = lock
    end

    def call
      User.transaction do
        @proto.updates.each do |user_update|
          User.find(user_update.user.id).update!(fields(user_update))
        end

        @proto.new.each { |new_user| User.create!(fields(new_user)) }

        @proto.families.each do |parent, family|
          User.where(id: family.map(&:id)).update_all(parent_id: parent.id)
        end

        @proto.completions.each do |user_completion|
          user = User.where(certificate: user_completion.user.certificate)
          CourseCompletion.create!(
            user_completion.completions.map do |completion|
              {
                user_id: user.id,
                key: completion.key,
                date: completion.date # DEV: Verify this data format is usable
              }
            end
          )
        end

        User.where(id: @proto.removed.map(&:id)).map(&:lock) if @lock
      end
    end

  private

    def fields(user_update)
      user_update.changes.each_with_object({}) { |c, h| h[c.field] = c.to }
    end
  end
end
