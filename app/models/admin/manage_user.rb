# == Schema Information
#
# Table name: admin_manage_users
#
#  id         :integer          not null, primary key
#  user_name  :string(255)
#  password   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'digest/sha1'

class Admin::ManageUser < ActiveRecord::Base
  before_save :encrypt_password

  def encrypt_password
    if self.password.present?
      self.password = Digest::SHA1.hexdigest(self.password)
    else
      self.password = self.password_was
    end
  end

  def registered?
    u = Admin::ManageUser.find_by(user_name: self.user_name, password: Digest::SHA1.hexdigest(self.password))
    if u != nil
      self.id = u.id
      true
    else
      false
    end
  end
end
