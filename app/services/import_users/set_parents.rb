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
        next unless (parent = parent(row))

        user = User.find_by(certificate: row['Certificate'])
        next if user.parent_id == parent.id

        update_parent_for(user, parent)
      end

      @families
    end

    private

    def update_parent_for(user, parent)
      user&.update(parent_id: parent.id)
      @families[user&.parent_id] ||= []
      @families[user&.parent_id] << user&.id
    end

    def parent(row)
      return if row['Prim.Cert'].blank?
      User.find_by(certificate: row['Prim.Cert'])
    end
  end
end
