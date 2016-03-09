class AddPrinterIdToUser < ActiveRecord::Migration
  def change
    add_column :user, :printer_id, :string
  end
end
