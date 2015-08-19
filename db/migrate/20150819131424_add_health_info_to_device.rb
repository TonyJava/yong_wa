class AddHealthInfoToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :health_info, :text
  end
end
