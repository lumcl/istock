json.array!(@printers) do |printer|
  json.extract! printer, :id, :uuid, :code, :name, :ip, :port, :creator_id, :updater_id
  json.url printer_url(printer, format: :json)
end
