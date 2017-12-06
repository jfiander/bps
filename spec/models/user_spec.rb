require 'rails_helper'

RSpec.describe User, type: :model do
  describe "permissions" do
    before(:all) do
      FactoryBot.build(:role, name: "admin").save(validate: false)
      FactoryBot.build(:role, name: "child", parent: Role.find_by(name: "admin")).save
      @user = FactoryBot.build(:user, email: "#{SecureRandom.hex(8)}@example.com}")
      @user.save
    end
    
    it "should return true when a user has the required permission" do
      @user.permit! :child
      @user.reload
      expect(@user.permitted?(:child)).to be(true)
    end
    
    it "should return true when a user has a parent of the required permission" do
      @user.unpermit! :child
      @user.permit! :admin
      @user.reload
      expect(@user.permitted?(:child)).to be(true)
    end
    
    it "should return false when a user does not have the required permission" do
      @user.unpermit! :child
      @user.unpermit! :admin
      @user.reload
      expect(@user.permitted?(:child)).to be(false)
    end
        
    it "should return false when a role doesn't exist" do
      expect(@user.permitted?(:not_a_permission)).to be(false)
    end

    it "should return false for invalid/empty permissions" do
      expect(@user.permitted?(nil)).to be(false)
      expect(@user.permitted?([])).to be(false)
      expect(@user.permitted?({})).to be(false)
    end
  end
end
