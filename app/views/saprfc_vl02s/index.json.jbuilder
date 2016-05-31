json.array!(@saprfc_vl02s) do |saprfc_vl02|
  json.extract! saprfc_vl02, :id, :VBELN, :POSNR, :MATNR, :CHARG, :MENGE, :MEINS, :WERKS, :LGORT, :MSG_TYPE, :MSG_ID, :MSG_NUMBER, :MSG_TEXT, :RFC_DATE, :STATUS, :MJAHR, :MBLNR, :ZEILE, :CREATOR, :UPDATER, :CREATED_AT, :UPDATED_AT, :BARCODE_ID
  json.url saprfc_vl02_url(saprfc_vl02, format: :json)
end
