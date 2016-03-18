class CreateSaprfcMb1b < ActiveRecord::Migration
  def change
    create_table :saprfc_mb1b, id: false do |t|
      t.string :uuid, null:false
      t.string :parent_id
      t.string :matnr
      t.string :werks
      t.string :lgort
      t.string :old_lgort
      t.string :charg
      t.string :bwart
      t.decimal :menge, precision: 15, scale: 3
      t.string :msg_type
      t.string :msg_id
      t.string :msg_number
      t.string :msg_text
      t.string :rfc_date
      t.string :status
      t.string :mjahr
      t.string :mblnr
      t.string :zeile
      t.string :creator
      t.string :updater

      t.timestamps null: false
    end
    add_index :saprfc_mb1b, :uuid, unique: true
    add_index :saprfc_mb1b, :parent_id
  end
end
