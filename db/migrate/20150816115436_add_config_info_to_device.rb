class AddConfigInfoToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :config_info, :text
  end
end
