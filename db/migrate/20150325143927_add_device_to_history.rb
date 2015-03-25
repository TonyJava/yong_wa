class AddDeviceToHistory < ActiveRecord::Migration
  def change
    add_reference :histories, :device, index: true
    add_foreign_key :histories, :devices
  end
end
