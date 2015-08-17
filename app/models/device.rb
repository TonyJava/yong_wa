#coding: utf-8
# == Schema Information
#
# Table name: devices
#
#  id            :integer          not null, primary key
#  series_code   :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sex           :string(255)
#  birth         :string(255)
#  height        :string(255)
#  weight        :string(255)
#  mobile        :string(255)
#  imei          :string(255)
#  device_name   :string(255)
#  active        :boolean
#  config_info   :text(65535)
#  tracking_info :text(65535)
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

  DEFAULT_TRACKING_RECORD = [
    {
      time: "101930",
      gps_sig: "A",
      geo_loc: "22.564025, N, 113.242329, E",
      velocity: "5.21",
      direction: "152",
      other: "..."
    }
  ]

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

  def get_tracking_record(begin_date, end_date)
    begin
      hash_data = JSON.parse(self.tracking_info, symbolize_names: true)
    rescue Exception => e
      puts e.message
      hash_data = {}
    end

    hash_selection = {}
    current_date = begin_date
    while DateString.compare_less_or_equal(current_date, end_date)
      hash_selection[current_date.to_sym] = hash_data[current_date.to_sym] || DEFAULT_TRACKING_RECORD
      current_date = DateString.next_day(current_date)
    end
    hash_selection
  end

  #response_report_geo
  #response_report_geo_2
  def add_tracking_record_geo(data_str)
    begin
      hash_data = JSON.parse(self.tracking_info, symbolize_names: true)
    rescue Exception => e
      puts e.message
      hash_data = {}
    end

    data_array = data_str.split(",")
    date_str = data_array[0]
    time_str = data_array[1]
    date_format = "20#{date_str[4..5]}-#{date_str[2..3]}-#{date_str[0..1]}"

    new_record = {}
    new_record[:time] = "#{time_str[0..1]}:#{time_str[2..3]}:#{time_str[4..5]}"
    new_record[:gps_sig] = data_array[2]
    new_record[:geo_loc] = data_array[3..6]
    new_record[:velocity] = data_array[7]
    new_record[:direction] = data_array[8]
    new_record[:other] = data_array[9..-1]

    if hash_data[date_format.to_sym] == nil
      hash_data[date_format.to_sym] = []
    end
    hash_data[date_format.to_sym].append(new_record)

    update(tracking_info: hash_data.to_json)
  end

  def self.find_device(device_str)
    Device.find_by(series_code: device_str)
  end

end
