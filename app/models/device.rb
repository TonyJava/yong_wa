class Device < ActiveRecord::Base
  belongs_to :user


  def self.exist?(device)
    device = Device.find_by(series_code: device)
    if device != nil
      true
    else
      false
    end
  end

end
