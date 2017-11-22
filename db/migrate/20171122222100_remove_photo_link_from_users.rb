class RemovePhotoLinkFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :photo_link, :string
  end
end
