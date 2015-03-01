json.array!(@admin_manage_users) do |admin_manage_user|
  json.extract! admin_manage_user, :id, :user_name, :password
  json.url admin_manage_user_url(admin_manage_user, format: :json)
end
