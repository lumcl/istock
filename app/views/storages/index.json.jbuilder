json.array!(@storages) do |storage|
  json.extract! storage, :id, :uuid, :code, :name, :werks
  json.url storage_url(storage, format: :json)
end
