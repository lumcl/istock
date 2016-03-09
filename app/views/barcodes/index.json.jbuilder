json.array!(@barcodes) do |barcode|
  json.extract! barcode, :id, :name, :stock_master_id, :parent_id, :child, :lgort, :status, :menge
  json.url barcode_url(barcode, format: :json)
end
