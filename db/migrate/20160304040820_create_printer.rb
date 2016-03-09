class CreatePrinter < ActiveRecord::Migration
  def change
    create_table :printer, id: false do |t|
      t.string :uuid, null: false
      t.string :code
      t.string :name
      t.string :ip
      t.string :port
      t.string :creator_id
      t.string :updater_id

      t.timestamps null: false
    end
    add_index :printer, :uuid, unique: true
    add_index :printer, :code
  end
end
