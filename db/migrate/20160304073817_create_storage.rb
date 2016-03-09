class CreateStorage < ActiveRecord::Migration
  def change
    create_table :storage, id: false do |t|
      t.string :uuid, null: false
      t.string :code
      t.string :name
      t.string :werks
      t.string :creator_id
      t.string :updater_id

      t.timestamps null: false
    end
    add_index :storage, :uuid, unique: true
    add_index :storage, :code
  end
end
