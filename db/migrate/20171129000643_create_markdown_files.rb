class CreateMarkdownFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :markdown_files do |t|
      t.attachment :file

      t.timestamps
    end
  end
end
