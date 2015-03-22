json.array!(@devices) do |device|
  json.extract! device, :id, :series_code
  json.url device_url(device, format: :json)
end
