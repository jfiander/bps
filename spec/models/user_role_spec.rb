# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRole do
  it 'preloads correctly' do
    admin = create(:role, name: 'admin')
    child = create(:role, name: 'child', parent: admin)
    users = create_list(:user, 2)
    users.each { |u| create(:user_role, user: u, role: child) }
    user_roles_hash = users.to_h { |u| [u.id, [:child]] }

    expect(described_class.preload).to eql(user_roles_hash)
  end
end
