class RemoveUserDeviceFromHistory < ActiveRecord::Migration
  def change
    remove_foreign_key :histories, :user_devices
    remove_reference :histories, :user_device, index: true 
  end
end
