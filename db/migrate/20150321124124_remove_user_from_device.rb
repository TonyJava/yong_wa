class RemoveUserFromDevice < ActiveRecord::Migration
  def change
    remove_foreign_key :devices, :users
    remove_reference :devices, :user, index: true
  end
end
