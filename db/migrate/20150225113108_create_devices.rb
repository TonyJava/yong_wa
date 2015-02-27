class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :series_code

      t.timestamps null: false
    end
  end
end
