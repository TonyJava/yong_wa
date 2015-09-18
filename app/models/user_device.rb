# == Schema Information
#
# Table name: user_devices
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  device_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_devices_on_device_id  (device_id)
#  index_user_devices_on_user_id    (user_id)
#

class UserDevice < ActiveRecord::Base
  belongs_to :user
  belongs_to :device
  validates :user_id, presence: true
  #validates :device_id, presence: true

  def mobile
    u = self.user
    u.mobile if u
  end

  def deviceId
    d = self.device
    d.series_code if d
  end
end
