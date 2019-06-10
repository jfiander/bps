# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRole, type: :model do
  it 'preloads correctly' do
    admin = FactoryBot.create(:role, name: 'admin')
    child = FactoryBot.create(:role, name: 'child', parent: admin)
    users = FactoryBot.create_list(:user, 2)
    users.each { |u| FactoryBot.create(:user_role, user: u, role: child) }
    user_roles_hash = { 1 => [:child], 2 => [:child] }

    expect(UserRole.preload).to eql(user_roles_hash)
  end
end
