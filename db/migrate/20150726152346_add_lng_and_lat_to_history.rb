class AddLngAndLatToHistory < ActiveRecord::Migration
  def change
    add_column :histories, :lng, :decimal, precision: 9, scale: 6
    add_column :histories, :lat, :decimal, precision: 9, scale: 6
  end
end
