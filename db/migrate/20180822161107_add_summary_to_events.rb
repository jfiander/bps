class AddSummaryToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :summary, :string
  end
end
