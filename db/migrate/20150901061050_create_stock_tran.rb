class CreateStockTran < ActiveRecord::Migration
  def change
    create_table :stock_tran, id: false do |t|
      t.string :uuid, null: false
      t.string :master_id
      t.string :barcode_id
      t.string :lgort_old
      t.string :lgort
      t.string :status
      t.integer :menge
      t.string :vbeln
      t.string :posnr
      t.string :meins
      t.string :mjahr
      t.string :mblnr
      t.string :zeile
      t.string :aufnr
      t.string :prdln
      t.string :ebeln
      t.string :ebelp
      t.string :mtype
      t.string :created_by
      t.string :created_ip
      t.string :created_mac
      t.string :updated_by
      t.string :updated_ip
      t.string :updated_mac

      t.timestamps null: false
    end
    add_index :stock_tran, :uuid, :unique => true
    add_index :stock_tran, :master_id
    add_index :stock_tran, :barcode_id

  end
end
