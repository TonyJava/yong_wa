json.array!(@histories) do |history|
  json.extract! history, :id, :user_device_id, :data_type, :data_content, :time_stamp, :location_code, :location_type, :data_stamp_address
  json.url history_url(history, format: :json)
end
