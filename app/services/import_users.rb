# frozen_string_literal: true

# Export all columns in the following list:
#
# 'Certificate', 'HQ Rank', 'SQ Rank', 'First Name', 'Last Name',
# 'Grade', 'Rank', 'E-Mail', 'MM', 'EdPro', 'EdAch', 'Senior', 'Life',
# 'IDEXPR', 'Address 1', 'Address 2', 'City', 'State', 'Zip Code',
# 'Home Phone', 'Cell Phone', 'Bus. Phone', 'Tot.Years', 'Prim.Cert'
#
# As well as all educational columns. You can also add a manual 'Rank' column.
#
class ImportUsers
  def call(path, lock: false)
    initialize_blank_variables

    User.transaction do
      parsed_csv = parse_csv(path)
      raise 'Blank header(s) detected.' if parsed_csv.headers.any?(&:blank?)

      parsed_csv.each { |row| parse_row(row) }
      set_parents(parsed_csv)
      lock_users?(lock)
    end

    File.unlink(path) if File.exist?(path)

    results_hash
  end

  private

  def initialize_blank_variables
    @created = []
    @updated = []
    @completions = []
    @families = {}
    @certificates = []
  end

  def parse_csv(path)
    CSV.parse(File.read(path).force_encoding('UTF-8'), headers: true)
  end

  def parse_row(row)
    if (user = find_user(row))
      update_user(user, row)
    else
      user = new_user(row)
    end
    course_completions(user, row)
    @certificates << row['Certificate']
  end

  def find_user(row)
    User.find_by(certificate: row['Certificate'])
  end

  def new_user(row)
    user = User.create!(
      {
        certificate: row['Certificate'],
        first_name: row['First Name'],
        last_name: row['Last Name'],
        email: import_email(row),
        password: SecureRandom.hex(16)
      }.merge(update_hash(row))
    )
    @created << user
    user
  end

  def update_user(user, row)
    # Ignores first name and last name because they are user-editable.
    # Ignores email, because that is used for login.
    user.assign_attributes(update_hash(row))
    unless user.changed.blank?
      @updated << { user.id => user.changes }
      user.save!
    end
    user
  end

  def import_email(row)
    if row['E-Mail'].present?
      if User.find_by(email: row['E-Mail'].downcase).present?
        "duplicate-#{SecureRandom.hex(8)}@bpsd9.org"
      else
        row['E-Mail'].downcase
      end
    else
      "nobody-#{SecureRandom.hex(8)}@bpsd9.org"
    end
  end

  def import_rank(row)
    return row['Rank']    if row['Rank']
    return row['SQ Rank'] if row['SQ Rank']
    return row['HQ Rank'] if row['HQ Rank']
    nil
  end

  def course_completions_data(row)
    row.to_hash.except(
      'Certificate', 'HQ Rank', 'SQ Rank', 'Rank', 'First Name', 'Last Name',
      'Grade', 'Rank', 'E-Mail', 'MM', 'EdPro', 'EdAch', 'Senior', 'Life',
      'IDEXPR', 'City', 'State', 'Address 1', 'Address 2', 'Zip Code',
      'Home Phone', 'Cell Phone', 'Bus. Phone', 'Tot.Years', 'Prim.Cert'
    )
  end

  def course_completions(user, row)
    course_completions_data(row).each do |(key, date)|
      date = clean_date(date)
      next if course_completion_exists?(user, key, date)

      @completions << CourseCompletion.create!(
        user: user, course_key: key, date: date
      )
    end
  end

  def course_completion_exists?(user, key, date)
    date.blank? ||
      CourseCompletion.find_by(user: user, course_key: key).present?
  end

  def clean_date(string)
    return if string.blank?

    begin
      fix_date(string)
    rescue StandardError
      puts "Invalid date: #{string}" unless Rails.env.test?
      return
    end
  end

  def fix_date(string)
    datestring = string.ljust(5, '0').ljust(6, '1')
    datestring[datestring.length - 1] = '1' if datestring.last(2) == '00'
    if datestring.length == 6
      Date.strptime(datestring, '%Y%m')
    elsif datestring.length == 8
      Date.strptime(datestring, '%Y%m%d')
    end
  end

  def update_hash(row)
    {
      rank: import_rank(row),
      grade: row['Grade'],
      address_1: row['Address 1'],
      address_2: row['Address 2'],
      city: row['City'],
      state: row['State'],
      zip: row['Zip Code'],
      mm: row['MM'],
      ed_pro: clean_date(row['EdPro']),
      ed_ach: clean_date(row['EdAch']),
      senior: clean_date(row['Senior']),
      life: clean_date(row['Life']),
      id_expr: clean_date(row['IDEXPR']),
      total_years: row['Tot.Years'],
      phone_h: row['Home Phone'],
      phone_c: row['Cell Phone'],
      phone_w: row['Bus. Phone']
    }
  end

  def results_hash
    {
      created: @created.map(&:id),
      updated: @updated.reduce({}, :merge),
      completions: @completions.map(&:id),
      families: @families,
      locked: @removed_users == :skipped ? :skipped : @removed_users.map(&:id)
    }
  end

  def lock_users?(lock)
    @removed_users = :skipped
    return unless lock

    @removed_users = User.where.not(certificate: @certificates).to_a
    auto_lock_removed_users
  end

  def auto_lock_removed_users
    # Do not auto-lock any current Bridge Officers.
    @removed_users.reject! { |u| u.in? BridgeOffice.all.map(&:user) }

    # Do not report previously-locked users.
    @removed_users.reject!(&:locked?)

    @removed_users.map(&:lock)
  end

  def set_parents(parsed_csv)
    parsed_csv.each do |row|
      next unless (parent = parent?(row))
      assign_parent(row, parent)
    end
  end

  def parent?(row)
    return if row['Prim.Cert'].blank?
    User.find_by(certificate: row['Prim.Cert'])
  end

  def assign_parent(row, parent)
    user = User.find_by(certificate: row['Certificate'])

    user&.update(parent_id: parent.id)

    @families[user&.parent_id] ||= []
    @families[user&.parent_id] << user&.id
  end
end
