# frozen_string_literal: true

module ImportUsers
  # Formatted hashes for user importing
  class Hash
    def initialize(row)
      @row = row
    end

    def update_user
      # Ignores first name and last name because they are user-editable.
      # Ignores email, because that is used for login.
      [user_personal, user_address, user_phone, user_education].inject(&:merge)
    end

    def new_user
      {
        certificate: @row['Certificate'],
        first_name: @row['First Name'],
        last_name: @row['Last Name'],
        email: import_email,
        password: SecureRandom.hex(16)
      }.merge(update_user)
    end

    private

    def import_email
      if @row['E-Mail'].present?
        if User.find_by(email: @row['E-Mail'].downcase).present?
          "duplicate-#{SecureRandom.hex(8)}@bpsd9.org"
        else
          @row['E-Mail'].downcase
        end
      else
        "nobody-#{SecureRandom.hex(8)}@bpsd9.org"
      end
    end

    def import_rank
      return @row['Rank']    if @row['Rank']
      return @row['SQ Rank'] if @row['SQ Rank']
      return @row['HQ Rank'] if @row['HQ Rank']
      nil
    end

    def user_personal
      {
        rank: import_rank,
        grade: @row['Grade'],
        mm: @row['MM'],
        senior: ImportUsers::CleanDate.new(@row['Senior']).call,
        life: ImportUsers::CleanDate.new(@row['Life']).call,
        total_years: @row['Tot.Years']
      }
    end

    def user_address
      {
        address_1: @row['Address 1'],
        address_2: @row['Address 2'],
        city: @row['City'],
        state: @row['State'],
        zip: @row['Zip Code']
      }
    end

    def user_phone
      {
        phone_h: @row['Home Phone'],
        phone_c: @row['Cell Phone'],
        phone_w: @row['Bus. Phone']
      }
    end

    def user_education
      {
        ed_pro: ImportUsers::CleanDate.new(@row['EdPro']).call,
        ed_ach: ImportUsers::CleanDate.new(@row['EdAch']).call,
        id_expr: ImportUsers::CleanDate.new(@row['IDEXPR']).call
      }
    end
  end
end
