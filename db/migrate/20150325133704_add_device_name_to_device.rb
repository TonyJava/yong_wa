class AddDeviceNameToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :device_name, :string
  end
end
