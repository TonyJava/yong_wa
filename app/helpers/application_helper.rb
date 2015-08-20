require 'net/http'
require 'uri'
require 'json'
module ApplicationHelper

  module Command
    TELEPHONE = 1
    COLLIDE   = 2
    SEND_POSITION_TIMES = 3
    BARRAGE = 4
    SEND_POSITION_ONCE = 5
    REPORT_POSITION = 6
    SILENT_PERIOD = 7
    CHECK_LOST = 8
  end

  #url: http://luosimao.com/docs/api/
  #url: http://ruby-doc.org/stdlib-2.2.0/libdoc/net/http/rdoc/Net/HTTP.html
  #res.code
  #res.message "OK"
  #res.body {"error":0,"msg":"ok"}
  #18118762813
  def send_captcha_to_mobile(mobile, captcha)
    uri = URI('http://sms-api.luosimao.com/v1/send.json')
    req = Net::HTTP::Post.new(uri)
    req.set_form_data("mobile" => mobile, "message" => "验证码:#{captcha}【快来运动】")
    req.basic_auth('api','key-b2b42c72fcba77b8f252c1aed4241297')
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    #{"error": 0,...}
    #{error: 0,...} symbolize_names: true
    logger.debug "#{res.body}"
    #binding.pry
    return JSON.parse(res.body, symbolize_names: true)[:error]
  end

  def send_server_info_to_watch(mobile)
    uri = URI('http://sms-api.luosimao.com/v1/send.json')
    req = Net::HTTP::Post.new(uri)
    req.set_form_data("mobile" => mobile, "message" => "120.25.212.225:2626")
    req.basic_auth('api','key-b2b42c72fcba77b8f252c1aed4241297')
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    logger.debug "#{res.body}"

    return JSON.parse(res.body, symbolize_names: true)[:error]
  end

  def send_fence_warning_for_device(device_model)
    user_devices = UserDevice.find_by(device: device_model)
    return if user_devices == nil
    user_devices.each do |u_d|
      mobile = u_d.user.mobile
      send_fence_warning_to_mobile(mobile, device_model.series_code)
    end
  end

  def send_fence_warning_to_mobile(mobile, device)
    uri = URI('http://sms-api.luosimao.com/v1/send.json')
    req = Net::HTTP::Post.new(uri)
    req.set_form_data("mobile" => mobile, "message" => "宝贝离开安全区域了！:#{device}")
    req.basic_auth('api','key-b2b42c72fcba77b8f252c1aed4241297')
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    logger.debug "#{res.body}"

    return JSON.parse(res.body, symbolize_names: true)[:error]
  end

end
