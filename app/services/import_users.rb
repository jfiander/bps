class ImportUsers
  def call(path)
    User.transaction do
      parse_csv(path).each do |row|
        user = user(row) || new_user(row)
        update_user(user, row)
        course_completions(row)
      end
    end

    File.unlink(path) if File.exist?(path)
  end

  private

  def parse_csv(path)
    CSV.parse(File.read(path).force_encoding('UTF-8'), headers: true)
  end

  def user(row)
    User.find_by(certificate: row['Certificate'])
  end

  def new_user(row)
    User.create!(
      certificate: row['Certificate'],
      first_name: row['First Name'],
      last_name: row['Last Name'],
      email: import_email(row),
      grade: row['Grade'],
      address_1: row['Address 1'],
      address_2: row['Address 2'],
      city: row['City'],
      state: row['State'],
      zip: row['Zip Code'],
      mm: row['MM'],
      ed_pro: row['EdPro'],
      id_expr: row['IDEXPR'],
      password: SecureRandom.hex(16)
    )
  end

  def update_user(user, row)
    # Ignores email, because that is used for login
    user.update!(
      first_name: row['First Name'],
      last_name: row['Last Name'],
      rank: import_rank(row),
      grade: row['Grade'],
      address_1: row['Address 1'],
      address_2: row['Address 2'],
      city: row['City'],
      state: row['State'],
      zip: row['Zip Code'],
      mm: row['MM'],
      ed_pro: row['EdPro'],
      id_expr: row['IDEXPR']
    )
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
    ''
  end

  def course_completions_data(row)
    row.to_hash.except(
      'Certificate', 'HQ Rank', 'SQ Rank', 'Rank', 'First Name', 'Last Name',
      'Grade', 'Rank', 'E-Mail', 'MM', 'EdPro', 'IDEXPR', 'City', 'State',
      'Address 1', 'Address 2', 'Zip Code'
    )
  end

  def course_completions(row)
    course_completions_data(row).each do |(key, date)|
      next if date.blank?
      next if CourseCompletion.find_by(user: user(row), course_key: key).present?

      CourseCompletion.create!(
        user: user(row),
        course_key: key,
        date: Date.strptime(date.ljust(5, '0').ljust(6, '1'), '%Y%m')
      )
    end
  end
end