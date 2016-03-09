class AddDateCodeToStockMaster < ActiveRecord::Migration
  def change
    add_column :stock_master, :datecode, :string
    add_column :stock_master, :budat, :string
  end
  add_index :stock_master, :aufnr
  add_index :stock_master, [:mjahr,:mblnr,:zeile]
end
