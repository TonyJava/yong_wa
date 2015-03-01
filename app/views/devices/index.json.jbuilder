json.array!(@devices) do |device|
  json.extract! device, :id, :series_code, :user_id
  json.url device_url(device, format: :json)
end
