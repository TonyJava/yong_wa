class CreateCellocations < ActiveRecord::Migration
  def change
    create_table :cellocations do |t|
      t.string :mnc
      t.string :zone_code
      t.string :station_code
      t.string :long
      t.string :lat

      t.timestamps null: false
    end
  end
end
