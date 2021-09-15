class AddLinkOverrideToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :link_override, :text
  end
end
