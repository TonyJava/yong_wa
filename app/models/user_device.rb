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

class UserDevice < ActiveRecord::Base
  belongs_to :user
  belongs_to :device
  validates :user_id, presence: true
  #validates :device_id, presence: true
end
