# frozen_string_literal: true

module BridgeHelper
  def bridge_selectors
    @select = {
      departments: BridgeOffice.departments.map { |b| [b.titleize, b] },
      bridge_offices: bridge_select_offices,
      standing_committees: StandingCommitteeOffice.committee_titles,
      users: bridge_select_users
    }
  end

  def preload_user_data
    @users = User.unlocked.order(:last_name).includes(
      :bridge_office, :committees, :standing_committee_offices
    )
    @all_bridge_officers = BridgeOffice.ordered
    @all_committees = Committee.sorted
    @standing_coms = StandingCommitteeOffice.current.chair_first
                                            .group_by(&:committee_name)
  end

  def build_bridge_list
    @standing_committee_data = {}

    @bridge_list = {
      departments: assemble_departments,
      standing_committees: assemble_standing_committees
    }
  end

  def assemble_departments
    BridgeOffice.departments.each_with_object({}) do |dept, hash|
      hash[dept.to_sym] = {
        head: generate_officer_hash(head(dept)),
        assistant: generate_officer_hash(asst(dept)),
        committees: generate_committees(dept)
      }
    end
  end

  def assemble_standing_committees
    @standing_coms.each do |committee, members|
      @standing_committee_data[committee] = []
      members.each do |member|
        user = get_user(member.user_id)
        @standing_committee_data[committee] << standing_committee(member, user)
      end
    end

    @standing_committee_data
  end

  def standing_committee(member, user)
    {
      id: member.id,
      simple_name: user[:simple_name],
      full_name: user[:full_name],
      chair: member.chair.present?,
      term_fraction: member.term_fraction
    }
  end

  def generate_officer_hash(officer)
    return unless officer.present?

    {
      title: officer.title,
      office: officer&.office,
      email: officer&.email,
      user: get_user(officer&.user_id)
    }
  end

  def generate_committees(dept)
    # html_safe: Text is sanitized before display.
    @all_committees[dept]&.map do |c|
      {
        name: sanitize(c.display_name).html_safe,
        user: get_user(c.user_id),
        id: c.id
      }
    end
  end

private

  def head(dept)
    @all_bridge_officers.find_all { |b| b.office == dept }.first
  end

  def asst(dept)
    @all_bridge_officers.find_all { |b| b.office == "asst_#{dept}" }.first
  end

  def bridge_select_offices
    BridgeOffice.departments(assistants: true).map do |b|
      [BridgeOffice.title(b), b]
    end
  end

  def bridge_select_users
    [['TBD', nil]] + @users.to_a.map do |user|
      [
        user&.full_name.blank? ? user.email : user.full_name(html: false),
        user.id
      ]
    end
  end
end
