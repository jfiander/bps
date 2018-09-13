class AddRepeatPatternToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :repeat_pattern, :string
  end
end
