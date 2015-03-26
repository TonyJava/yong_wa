class RemoveTimeStampFromHistory < ActiveRecord::Migration
  def change
    remove_column :histories, :time_stamp, :datetime
  end
end
