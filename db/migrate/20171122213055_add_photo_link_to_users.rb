class AddPhotoLinkToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :photo_link, :string
  end
end
