class AddRoleToAdminManagerUser < ActiveRecord::Migration
  def change
    add_column :admin_manage_users, :role, :integer
  end
end
