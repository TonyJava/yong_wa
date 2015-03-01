class CreateAdminManageUsers < ActiveRecord::Migration
  def change
    create_table :admin_manage_users do |t|
      t.string :user_name
      t.string :password

      t.timestamps null: false
    end
  end
end
