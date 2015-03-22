class CreateUserDevices < ActiveRecord::Migration
  def change
    create_table :user_devices do |t|
      t.references :user, index: true
      t.references :device, index: true

      t.timestamps null: false
    end
    add_foreign_key :user_devices, :users
    add_foreign_key :user_devices, :devices
  end
end
