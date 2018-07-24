class AddPhonesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :phone_h, :string
    add_column :users, :phone_c, :string
    add_column :users, :phone_w, :string
  end
end
