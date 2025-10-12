class CreateFeeds < ActiveRecord::Migration[8.0]
  def change
    create_table :feeds do |t|
      t.string :url, null: false
      t.string :title
      t.datetime :last_fetched_at
      t.timestamps
    end

    add_index :feeds, :url, unique: true
  end
end
