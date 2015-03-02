require 'net/http'
require 'uri'
require 'json'
module ApplicationHelper

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
    req.basic_auth('api','key-810cec56574191d135b1d1e7cf83a4e4')
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    #{"error": 0,...}
    #{error: 0,...} symbolize_names: true
    logger.debug "#{res.body}"
    binding.pry
    return JSON.parse(res.body, symbolize_names: true)[:error]
  end

end
