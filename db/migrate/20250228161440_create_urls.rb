class CreateUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :urls do |t|
      t.text :url, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :urls, :slug, unique: true
    add_index :urls, :url
  end
end
