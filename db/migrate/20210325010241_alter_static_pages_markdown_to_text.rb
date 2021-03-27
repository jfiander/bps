class AlterStaticPagesMarkdownToText < ActiveRecord::Migration[5.2]
  def up
    change_column :static_pages, :markdown, :text
  end

  def down
    change_column :static_pages, :markdown, :string
  end
end
