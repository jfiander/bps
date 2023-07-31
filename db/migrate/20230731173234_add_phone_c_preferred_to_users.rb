class AddPhoneCPreferredToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :phone_c_preferred, :string
  end
end
