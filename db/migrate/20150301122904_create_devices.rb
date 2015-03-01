class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :series_code
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :devices, :users
  end
end
