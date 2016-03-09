class CreateStockMaster < ActiveRecord::Migration
  def change
    create_table :stock_master, id: false do |t|
      t.string :uuid, null: false
      t.string :matnr
      t.string :maktx
      t.string :matkl
      t.string :charg
      t.integer :menge
      t.integer :box_cnt
      t.integer :pallet_cnt
      t.string :werks
      t.string :meins
      t.string :mjahr
      t.string :mblnr
      t.string :zeile
      t.string :aufnr
      t.string :prdln
      t.string :ebeln
      t.string :ebelp

      t.timestamps null: false
    end
    add_index :stock_master, :uuid, :unique => true
    add_index :stock_master, :matnr
  end
end
