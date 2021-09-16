class AddConferenceSignatureToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :conference_signature, :string
  end
end
