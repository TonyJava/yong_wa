class AddTrackingInfoToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :tracking_info, :text
  end
end
