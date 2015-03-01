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
