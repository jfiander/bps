class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :trackable, :validatable, :timeoutable, :lockable
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_one  :bridge_office
  has_many :standing_committee_offices
  has_many :committees

  has_many :course_completions

  has_many :event_instructors
  has_many :events, through: :event_instructors

  def self.no_photo
    ActionController::Base.helpers.image_path(User.buckets[:static].link('no_profile.png'))
  end

  has_attached_file :profile_photo,
    default_url: User.no_photo,
    storage: :s3,
    s3_region: 'us-east-2',
    path: 'profile_photos/:id/:style/:filename',
    s3_permissions: :private,
    s3_credentials: aws_credentials(:files),
    styles: { medium: '500x500', thumb: '200x200' }

  before_validation do
    self.rank = nil if self.rank.blank?
    self.simple_name = "#{first_name} #{last_name}"
  end

  validate :valid_rank, :valid_grade
  validates_attachment_content_type :profile_photo, content_type: /\Aimage\//
  validates_attachment_file_name :profile_photo, matches: [/\.png\Z/, /\.jpe?g\Z/]
  validates :certificate, uniqueness: true, allow_nil: true

  scope :locked,         -> { where.not(locked_at: nil) }
  scope :unlocked,       -> { where.not(id: locked) }
  scope :alphabetized,   -> { order(:last_name) }
  scope :with_positions, -> { includes(:bridge_office, :standing_committee_offices, :committees, :user_roles, :roles) }
  scope :with_name,      ->(name) { where(simple_name: name) }
  scope :with_a_name,    -> { where.not(simple_name: [nil, '', ' ']) }
  scope :invitable,      -> { unlocked.where('sign_in_count = 0').reject(&:has_placeholder_email?) }

  acts_as_paranoid

  def full_name(html: true)
    (auto_rank.present? ? "#{auto_rank(html: html)} " : '') +
    simple_name +
    (grade.present? ? ", #{grade}" : '')
  end

  def photo(style: :medium)
    if profile_photo.present? && User.buckets[:files].object(profile_photo.s3_object.key).exists?
      User.buckets[:files].link(profile_photo.s3_object(style).key)
    else
      User.no_photo
    end
  end

  def bridge_hash
    {
      full_name: full_name.gsub(' ', '&nbsp;').html_safe,
      simple_name: simple_name.gsub(' ', '&nbsp;').html_safe,
      photo: photo
    }
  end

  def register_for(event)
    Registration.create(user: self, event: event)
  end

  def request_from_store(item_id)
    ItemRequest.create(user: self, store_item_id: item_id)
  end

  def permitted?(*required_roles, &block)
    return false if required_roles.blank? || required_roles.all? { |r| r.blank? }
    permitted = permitted_roles.any? { |p| p.in? required_roles.reject(&:nil?).map(&:to_sym) }

    yield if permitted && block_given?
    permitted
  end

  def granted_roles
    roles.map(&:name).map(&:to_sym).uniq
  end

  def permitted_roles
    [
      explicit_roles,
      implicit_roles
    ].flatten.uniq.reject(&:nil?)
  end

  def permit!(role)
    role = Role.find_by(name: role.to_s)
    UserRole.find_or_create(user: self, role: role)
  end

  def unpermit!(role)
    UserRole.where(user: self).destroy_all and return true if role == :all
    UserRole.where(user: self, role: Role.find_by(name: role.to_s)).destroy_all.present?
  end

  def locked?
    locked_at.present?
  end

  def lock
    update(locked_at: Time.now)
  end

  def unlock
    update(locked_at: nil)
  end

  def invitable?
    invitation_accepted_at.blank? &&
      current_sign_in_at.blank? &&
      !locked? &&
      sign_in_count.zero? &&
      !has_placeholder_email?
  end

  def invited?
    invitation_sent_at.present? &&
      invitation_accepted_at.blank?
  end

  def has_placeholder_email?
    email.match(/nobody-.*@bpsd9\.org/) ||
      email.match(/duplicate-.*@bpsd9\.org/)
  end

  def self.valid_ranks
    %w[P/Lt/C P/C 1/Lt Lt/C Cdr Lt F/Lt P/D/Lt/C P/D/C D/1/Lt D/Lt/C D/C D/Lt D/Aide D/F/Lt P/Stf/C P/R/C P/V/C P/C/C N/Aide N/F/Lt P/N/F/Lt Stf/C R/C V/C C/C]
  end

  def self.valid_grades
    %w[S P AP JN N SN]
  end

  def self.import(path)
    User.transaction do
      all_problems = []
      CSV.parse(File.read(path).force_encoding('UTF-8'), headers: true).each do |row|
        user = User.find_by(certificate: row['Certificate'])
        email = row['E-Mail'].present? ? row['E-Mail'].downcase : "nobody-#{SecureRandom.hex(8)}@bpsd9.org"
        email = "duplicate-#{SecureRandom.hex(8)}@bpsd9.org" if User.where(email: email).count > 0
        rank = if row.has_key?('Rank') && row['Rank'].present?
          row['Rank']
        elsif row.has_key?('SQ_Rank') && row['SQ_Rank'].present?
          row['SQ_Rank']
        elsif row.has_key?('HQ_Rank') && row['HQ_Rank'].present?
          row['HQ_Rank']
        else
          ''
        end
        user = User.create!(certificate: row['Certificate'], first_name: row['First Name'], last_name: row['Last Name'], email: email, grade: row['Grade'], password: SecureRandom.hex(16)) unless user.present?

        user.update(rank: rank, grade: row['Grade'], mm: row['MM'], ed_pro: row['EdPro'], id_expr: row['IDEXPR'])
        ['Certificate', 'First Name', 'Last Name', 'Grade', 'Rank', 'E-Mail', 'MM', 'EdPro', 'IDEXPR'].each { |column| row.delete(column) }

        row.each do |(key, date)|
          next unless date.present?
          date = "#{date}0" while date.to_s.length < 6
          date = "#{date[0..4]}1" if date.match /00$/
          date = Date.strptime(date, '%Y%m')
          CourseCompletion.create!(user: user, course_key: key, date: date) unless CourseCompletion.find_by(user: user, course_key: key).present?
        end
      end
    end

    File.unlink(path) if File.exist?(path)
  end

  def auto_rank(html: true)
    highest_rank(*ranks(html: html))
  end

  def ranks(html: true)
    bridge_rank = case bridge_office&.office
    when 'commander'
      'Cdr'
    when 'executive', 'administrative', 'educational', 'secretary', 'treasurer'
      'Lt/C'
    when 'asst_educational', 'asst_secretary'
      html ? '1<sup>st</sup>/Lt'.html_safe : '1st/Lt'
    end

    committee_rank = 'Lt' if standing_committee_offices.present? || committees.present?
    committee_rank = 'F/Lt' if 'Flag Lieutenant'.in? committees.map(&:name)

    [bridge_rank, rank, committee_rank].reject(&:blank?)
  end

  # private
  def office_roles
    [
      permitted_roles_from_bridge_office,
      permitted_roles_from_committee
    ].flatten.uniq.reject(&:nil?)
  end

  def explicit_roles
    [
      granted_roles,
      office_roles
    ].flatten.uniq.reject(&:nil?)
  end

  def implicit_roles
    all_roles ||= Role.all.to_a
    search_roles = explicit_roles

    role_objs = search_roles.map do |role|
      all_roles.find_all { |r| r.name == role.to_s }
    end.flatten

    collected_roles = []
    done = false
    until done
      new_roles = role_objs.map do |role|
        all_roles.find_all { |r| r.parent_id == role.id }
      end.flatten

      size = collected_roles.size
      collected_roles = collected_roles.push(new_roles).uniq
      done = true if collected_roles.size == size
    end

    collected_roles.flatten.map(&:name).map(&:to_sym)
  end

  def implicit_permissions
    permissions = File.read("#{Rails.root}/config/implicit_permissions.yml")
    @implicit_permissions ||= YAML.safe_load(permissions)
  end

  def permitted_roles_from_bridge_office
    implicit_permissions['bridge_office'][bridge_office&.office].map(&:to_sym)
  end

  def permitted_roles_from_committee
    implicit_permissions['committee'].select do |k, _|
      k.in? committees.map(&:search_name)
    end.values.flatten.map(&:to_sym)
  end

  def valid_rank
    return true if rank.nil?
    return true if rank.in? User.valid_ranks
    errors.add(:rank, 'must be nil or in User.valid_ranks')
  end

  def valid_grade
    return true if grade.nil?
    return true if grade.in? User.valid_grades
    errors.add(:grade, 'must be nil or in User.valid_grades')
  end

  def highest_rank(*ranks)
    rank_priority = {
      'C/C'      => 1,
      'P/C/C'    => 2,
      'V/C'      => 3,
      'P/V/C'    => 4,
      'R/C'      => 5,
      'P/R/C'    => 6,
      'D/C'      => 7,
      'P/D/C'    => 8,
      'Stf/C'    => 9,
      'P/Stf/C'  => 10,
      'Cdr'      => 11,
      'P/C'      => 12,
      'N/F/Lt'   => 13,
      'P/N/F/Lt' => 14,
      'N/Chpln'  => 15,
      'Aide/CC'  => 16,
      'D/Lt/C'   => 17,
      'P/D/Lt/C' => 18,
      'D/1st/Lt' => 19,
      'D/1<sup>st</sup>/Lt' => 19,
      'D/1/Lt'   => 19,
      'D/F/Lt'   => 20,
      'D/Lt'     => 21,
      'Lt/C'     => 22,
      'P/Lt/C'   => 23,
      '1st/Lt'   => 24,
      '1<sup>st</sup>/Lt'  => 24,
      '1/Lt'     => 24,
      'F/Lt'     => 25,
      'Lt'       => 26
    }

    ranks.map { |r| {r => (rank_priority[r] || 100) } }.reduce({}, :merge).min_by { |_, p| p }&.first
  end
end
