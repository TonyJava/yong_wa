class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.references :user_device, index: true
      t.integer :data_type
      t.string :data_content
      t.datetime :time_stamp
      t.string :location_code
      t.string :location_type
      t.string :data_stamp_address

      t.timestamps null: false
    end
    add_foreign_key :histories, :user_devices
  end
end
