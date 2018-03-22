module Import
  def self.import(path)
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
      password: SecureRandom.hex(16)
    )
  end

  def update_user(user, row)
    user.update(
      first_name: row['First Name'],
      last_name: row['Last Name'],
      email: import_email(row),
      rank: import_rank(row),
      grade: row['Grade'],
      mm: row['MM'],
      ed_pro: row['EdPro'],
      id_expr: row['IDEXPR']
    )
  end

  def import_email(row)
    if row['E-Mail'].present?
      unless User.where(email: email).count.positive?
        return row['E-Mail'].downcase
      end
      "duplicate-#{SecureRandom.hex(8)}@bpsd9.org"
    else
      "nobody-#{SecureRandom.hex(8)}@bpsd9.org"
    end
  end

  def import_rank(row)
    return row['Rank']    if rank?(row)
    return row['SQ_Rank'] if sq_rank?(row)
    return row['HQ_Rank'] if hq_rank?(row)
    ''
  end

  def rank?(row)
    row.key?('Rank') && row['Rank'].present?
  end

  def sq_rank?(row)
    row.key?('SQ_Rank') && row['SQ_Rank'].present?
  end

  def hq_rank?(row)
    row.key?('HQ_Rank') && row['HQ_Rank'].present?
  end

  def course_completions_data(row)
    %w[
      Certificate First Name Last Name Grade Rank E-Mail MM EdPro IDEXPR
    ].each { |column| row.delete(column) }
    row
  end

  def course_completions(row)
    course_completions_data(row).each do |(key, date)|
      next if date.blank?
      next if CourseCompletion.find_by(user: user, course_key: key).present?

      CourseCompletion.create!(
        user: user,
        course_key: key,
        date: Date.strptime(date.ljust(5, '0').ljust(6, '1'), '%Y%m')
      )
    end
  end
end
