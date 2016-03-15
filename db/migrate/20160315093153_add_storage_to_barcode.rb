class AddStorageToBarcode < ActiveRecord::Migration
  def change
    add_column :barcode, :storage, :string
    add_index :barcode, :storage
  end
end
