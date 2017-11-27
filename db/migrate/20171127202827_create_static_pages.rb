class CreateStaticPages < ActiveRecord::Migration[5.0]
  def change
    create_table :static_pages do |t|
      t.string :name
      t.string :markdown

      t.timestamps
    end
  end
end
