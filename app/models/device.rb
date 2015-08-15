# == Schema Information
#
# Table name: devices
#
#  id          :integer          not null, primary key
#  series_code :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sex         :string(255)
#  birth       :string(255)
#  height      :string(255)
#  weight      :string(255)
#  mobile      :string(255)
#  imei        :string(255)
#  device_name :string(255)
#  active      :boolean
#

class Device < ActiveRecord::Base
  has_many :user_device
  has_many :history

  def self.exist?(device)
    device = Device.find_by(series_code: device)
    if device != nil
      true
    else
      false
    end
  end

end
