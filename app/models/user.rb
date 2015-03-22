require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :user_device
  has_secure_token :auth_token
	#validates :mobile, format: { with: /^0?(13[0-9]|15[012356789]|18[0236789]|14[57])[0-9]{8}$/, message: "mobile format error."}
  before_save :encrypt_password
  after_save :clear_captcha_cache

  def encrypt_password
    #only after change password
    unless self.password_changed?
      return
    end

    if self.password.present?
      self.password = Digest::SHA1.hexdigest(self.password)
    else
      self.password = self.password_was
    end
  end

  def self.mobile_format_valid?(mobile)
    mobile_regx = /^0?(13[0-9]|15[012356789]|18[01236789]|14[57])[0-9]{8}$/
    if mobile_regx === mobile
      true
    else
      false
    end
  end

  def self.password_format_valid?(password)
    password_regx = /^[a-z0-9_-]{6,16}$/
    if password_regx === password
      true
    else
      false
    end
  end

  def self.registered?(mobile)
    u = User.find_by(mobile: mobile)
    if u != nil
      true
    else
      false
    end
  end

  def self.auth?(mobile, password)
    u = User.find_by(mobile: mobile, password: Digest::SHA1.hexdigest(password))
    if u != nil
      true
    else
      false
    end
  end

  def clear_captcha_cache
    $redis.del self.mobile
  end
end
