class AddCalendarRuleIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :calendar_rule_id, :string
  end
end
