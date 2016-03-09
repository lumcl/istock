class AddSeqToBarcode < ActiveRecord::Migration
  def change
    add_column :barcode, :seq, :integer
    add_index :barcode, :seq
  end
end
