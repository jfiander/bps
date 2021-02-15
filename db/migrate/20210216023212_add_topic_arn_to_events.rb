class AddTopicArnToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :topic_arn, :string
  end
end
