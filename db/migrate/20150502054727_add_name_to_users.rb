class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :user, :username, :string
    add_column :user, :role, :string
    add_column :user, :supplier_id, :integer
    add_column :user, :territory, :string
    add_index :user, :username, unique: true
  end
end
