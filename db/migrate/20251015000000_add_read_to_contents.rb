class AddReadToContents < ActiveRecord::Migration[8.0]
  def change
    add_column :contents, :read, :boolean, default: false, null: false
    add_index :contents, :read
  end
end
