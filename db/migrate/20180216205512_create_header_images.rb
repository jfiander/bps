class CreateHeaderImages < ActiveRecord::Migration[5.0]
  def change
    create_table :header_images do |t|
      t.attachment :file
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
