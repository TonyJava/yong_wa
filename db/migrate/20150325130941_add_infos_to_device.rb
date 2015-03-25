class AddInfosToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :sex, :string
    add_column :devices, :birth, :string
    add_column :devices, :height, :string
    add_column :devices, :weight, :string
    add_column :devices, :mobile, :string
    add_column :devices, :imei, :string
  end
end
