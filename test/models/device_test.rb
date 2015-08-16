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
#  config_info :text(65535)
#

require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
