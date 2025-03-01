class CreateStatistics < ActiveRecord::Migration[8.0]
  def change
    create_table :statistics do |t|
      t.string :user_agent
      t.string :referrer
      t.string :ip
      t.string :country
      t.integer :url_id, null: false

      t.timestamps
    end
  end
end
