json.array!(@stock_trans) do |stock_tran|
  json.extract! stock_tran, :id, :master_id, :barcode_id, :lgort_old, :lgort, :status, :qty, :vbeln, :posnr, :meins, :mjahr, :mblnr, :zeile, :aufnr, :prdln, :ebeln, :ebelp, :mtype, :created_by, :created_ip, :created_mac, :updated_by, :updated_ip, :updated_mac
  json.url stock_tran_url(stock_tran, format: :json)
end
