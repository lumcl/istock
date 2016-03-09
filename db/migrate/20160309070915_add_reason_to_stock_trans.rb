class AddReasonToStockTrans < ActiveRecord::Migration
  def change
    add_column :stock_tran, :reason, :text
  end
end
