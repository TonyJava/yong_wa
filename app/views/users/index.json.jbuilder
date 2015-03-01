json.array!(@users) do |user|
  json.extract! user, :id, :mobile, :password, :auth_token
  json.url user_url(user, format: :json)
end
