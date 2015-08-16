#coding: utf-8
# == Schema Information
#
# Table name: devices
#
#  id          :integer          not null, primary key
#  series_code :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sex         :string(255)
#  birth       :string(255)
#  height      :string(255)
#  weight      :string(255)
#  mobile      :string(255)
#  imei        :string(255)
#  device_name :string(255)
#  active      :boolean
#  config_info :text(65535)
#

class Device < ActiveRecord::Base
  has_many :user_device
  has_many :history

  DEFAULT_CONFIG = {
    sos: [
          "18565739316",
          "18062069679",
          "13000003434"
      ],

    communicationRecord: [
      {
        name: "伙伴一",
        mobile: "18565739316"
        },
      {
        name: "伙伴二",
        mobile: "18565739316"
        },
      {
        name: "伙伴三",
        mobile: "18565739316"
        } 
      ],

    workingMode: {
      description: "正常模式:10分钟/次",
      code: "1"
    },

    freeTime: [
        {
          beginTime: "00:00",
          endTime: "09:00"
          },
        {
          beginTime: "14:00",
          endTime: "15:00"
          },
        {
          beginTime: "20:00",
          endTime: "21:00"
          }
      ],

    schoolPositioning: [
        {
          beginTime: "00:00",
          endTime: "09:00"
          },
        {
          beginTime: "14:00",
          endTime: "15:00"
          },
        {
          beginTime: "20:00",
          endTime: "21:00"
          }
      ],

    weekendPositioning: [
        {
          beginTime: "00:00",
          endTime: "09:00"
          },
        {
          beginTime: "14:00",
          endTime: "15:00"
          },
        {
          beginTime: "20:00",
          endTime: "21:00"
        }
      ],

    SMSSettings: [
      {
        name: "低电提醒",
        state: "1"
        },
      {
        name: "SOS提醒",
        state: "1"
      }
    ]
  }

  def self.exist?(device)
    device = Device.find_by(series_code: device)
    if device != nil
      true
    else
      false
    end
  end

  def get_config
    if !self.config_info
      self.config_info = DEFAULT_CONFIG.to_json
      self.save!
    end
    JSON.parse(self.config_info, symbolize_names: true)
  end

  def set_config_field(key, value)
    self.config_info ||= DEFAULT_CONFIG.to_json
    hash_values = JSON.parse(config_info, symbolize_names: true)
    hash_values[key.to_sym] = value
    update!(config_info: hash_values.to_json)
  end

  def get_config_field(key)
    info = self.config_info || DEFAULT_CONFIG.to_json
    hash_values = JSON.parse(config_info, symbolize_names: true)
    hash_values[key.to_sym]
  end

end
