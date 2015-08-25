class AddDataDescriptionToHistories < ActiveRecord::Migration
  def change
    add_column :histories, :data_description, :string
  end
end
