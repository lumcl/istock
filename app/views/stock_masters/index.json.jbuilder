json.array!(@stock_masters) do |stock_master|
  json.extract! stock_master, :id, :matnr, :maktx, :matkl, :charg, :menge, :box_cnt, :pallet_cnt, :werks, :meins, :mjahr, :mblnr, :zeile, :aufnr, :prdln, :ebeln, :ebelp
  json.url stock_master_url(stock_master, format: :json)
end
