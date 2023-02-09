# frozen_string_literal: true

module ImportUsers
  # Parent association setter for user importing
  class SetParents
    def initialize(csv)
      @csv = csv
      @families = {}
    end

    def call
      @csv.each do |row|
        user, user_parent = user_and_parent(row)
        next unless user_parent.present?

        update_parent_for(user, user_parent)
      end

      @families
    end

  private

    def update_parent_for(user, parent)
      @families[user&.parent] ||= []
      @families[user&.parent] << user
    end

    def user_and_parent(row)
      return if row['Prim.Cert'].blank?

      user = User.find_by(certificate: row['Certificate'])
      parent = User.find_by(certificate: row['Prim.Cert'])
      return if user.parent_id == parent.id

      [user, parent]
    end
  end
end
