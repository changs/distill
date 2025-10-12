class CreateContents < ActiveRecord::Migration[8.0]
  def change
    create_table :contents do |t|
      t.references :feed, null: false, foreign_key: true
      t.string :url, null: false
      t.string :title
      t.text :content
      t.text :summary
      t.datetime :published_at
      t.timestamps
    end

    add_index :contents, :url, unique: true
    add_index :contents, :published_at
  end
end
