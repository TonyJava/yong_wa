class ChangeDeviceTrackingInfoLength < ActiveRecord::Migration
  def up
    change_column :devices, :tracking_info, :text, :limit => 16777215
  end
  def down
    change_column :devices, :tracking_info, :text, :limit => 65535
  end
end
