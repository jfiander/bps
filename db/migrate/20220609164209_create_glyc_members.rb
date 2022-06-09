class CreateGLYCMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :glyc_members do |t|
      t.string :email
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
