# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Admin::ManageUser.delete_all
Admin::ManageUser.create(user_name: "admin", password: "admin")

start_id = 1150900001
while start_id <= 1150910000
  deviceId = start_id.to_s
  Device.create(series_code: deviceId)
  start_id += 1
end