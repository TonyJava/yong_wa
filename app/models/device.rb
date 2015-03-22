class Device < ActiveRecord::Base
  has_many :user_device


  def self.exist?(device)
    device = Device.find_by(series_code: device)
    if device != nil
      true
    else
      false
    end
  end

end
