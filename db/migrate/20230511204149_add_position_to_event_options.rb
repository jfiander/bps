class AddPositionToEventOptions < ActiveRecord::Migration[6.1]
  def change
    add_column :event_options, :position, :integer
  end
end
