class ChangeDataContentFormatInHistory < ActiveRecord::Migration
  def up
    change_column :histories, :data_content, :text
  end
  def down
    change_column :histories, :data_content, :string
  end
end
