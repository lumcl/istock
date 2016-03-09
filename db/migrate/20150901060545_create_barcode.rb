class CreateBarcode < ActiveRecord::Migration
  def change
    create_table :barcode, id: false do |t|
      t.string :uuid, null: false
      t.string :name
      t.string :stock_master_id
      t.string :parent_id
      t.string :child
      t.string :old_id
      t.string :lgort
      t.string :status
      t.integer :menge

      t.timestamps null: false
    end
    add_index :barcode, :uuid, unique: true
    add_index :barcode, :name
  end
end
