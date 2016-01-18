class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nickname, :string, null: false, default: ''
    add_index :users, :nickname, unique: true
  end
end
