# == Schema Information
#
# Table name: histories
#
#  id                 :integer          not null, primary key
#  data_type          :integer
#  data_content       :text(65535)
#  location_code      :string(255)
#  location_type      :string(255)
#  data_stamp_address :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  device_id          :integer
#  lng                :decimal(9, 6)
#  lat                :decimal(9, 6)
#
# Indexes
#
#  index_histories_on_device_id  (device_id)
#

class History < ActiveRecord::Base
  belongs_to :device
end
