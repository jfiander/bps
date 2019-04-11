# frozen_string_literal: true

module Excom
  def update_excom_group
    r = excom_group_members - excom_emails
    a = excom_emails - excom_group_members

    update_group_emails(a, r)
    display_summary(a, r)
  end

private

  def excom_emails
    bridge = BridgeOffice.includes(:user).heads.map(&:user)
    at_large = StandingCommitteeOffice.includes(:user).where(committee_name: 'executive').map(&:user)

    [bridge, at_large].flatten.compact.map(&:email)
  end

  def excom_group_members
    excom_group.members.members.map(&:email)
  end

  def excom_group
    @excom_group ||= GoogleAPI::Group.new('excom@bpsd9.org')
  end

  def update_group_emails(add, remove)
    add.each { |email| excom_group.add(email) } if ENV['ASSET_ENVIRONMENT'] == 'production'
    remove.each { |email| excom_group.remove(email) } if ENV['ASSET_ENVIRONMENT'] == 'production'
  end

  def display_summary(add, remove)
    hash = { add: add, remove: remove }
    logger.info { "*** Updating ExCom email group: #{hash}" }
    hash
  end
end
