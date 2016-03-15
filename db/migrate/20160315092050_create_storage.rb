class CreateStorage < ActiveRecord::Migration
  def change
    create_table :storage do |t|
      t.string :uuid
      t.string :CODE
      t.string :NAME
      t.string :WERKS
      t.string :creator_id
      t.string :updater_id

      t.timestamps null: false
    end
    add_index :storage, :uuid, unique: true
    add_index :storage, :code
  end
end
