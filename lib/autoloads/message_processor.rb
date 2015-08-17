#coding: utf-8
require "socket"


class MessageProcessor

  HEAD = "SG"

  public

  def initialize(args)
    @@head = "SG"
    @@mid = "8800000015" 
  end  

  # receive message
  def self.in_command(sock, str)
    #a = /(.)\*/.match(str)

    # check voice message

    #use chomp instead
    #str = str.strip

    begin
      a = str.split('*', 4)
      device = a[1]

      if device && !$socket_device[sock]
        $socket_device[sock] = device
        puts "connect new device: #{device}"
      end

      b = a[3]
      c = b.split(',', 2)
      case c[0]
      when 'TK'
        response_voice_message(sock, device, c[1])
      when 'LK'
        response_keep_connect(sock, device, c[1])
        #Resque.enqueue(ResqueTestSendMessage)
      when 'UD'
        response_report_geo(sock, device, c[1])
      when 'UD2'
        response_report_geo_2(sock, device, c[1])
      when 'AL'
        response_alarm_data(sock, device, c[1])
      when 'WAD'
        response_address_data(sock, device, c[1])
      when 'WG'
        response_lat_lng_data(sock, device, c[1])

      when 'UPLOAD'
        #upload
        response_data_upload_interval(sock, device, c[1])
      when 'CENTER'
        response_center_number(sock, device, c[1])
      when 'SLAVE'
        response_assist_center_number(sock, device, c[1])
      when 'PW'
        response_password(sock, device, c[1])
      when 'CALL'
        response_call(sock, device, c[1])
      when 'SMS'
        response_sms(sock, device, c[1])
      when 'MONITOR'
        response_monitor(sock, device, c[1])
      when 'SOS'
      when 'SOS1'
      when 'SOS2'
      when 'SOS3'
        response_sos_number(sock, device, c[0])
      when 'UPGRADE'
        response_upgrade(sock, device, c[0])
      when 'IP'
      
      when 'FACTORY'
        response_factory(sock, device, c[0])
      when 'LZ'
        response_language_time_zone(sock, device, c[0])
      when 'URL'
        response_google_url(sock, device, c[1])
      when 'SOSSMS'
        response_sos_alarm(sock, device, c[0])
      when 'LOWBAT'
        response_battery_alarm(sock, device, c[0])
      when 'APN'
        response_apn(sock, device, c[0])
      when 'ANY'
        response_sms_control(sock, device, c[0])
      when 'TS'
        response_status(sock, device, c[1])
      when 'VERNO'
        response_version(sock, device, c[1])
      when 'RESET'
        response_reset(sock, device, c[0])
      when 'CR'
        response_active_pos(sock, device, c[0])
      when 'BT'
        response_blue_tooth_control(sock, device, c[0])
      when 'WORK'
        response_work_period(sock, device, c[0])
      when 'WORKTIME'
        response_work_time(sock, device, c[0])
      when 'POWEROFF'
        response_power_off(sock, device, c[0])
      when 'REMOVE'
        response_remove(sock, device, c[0])
      when 'PULSE'
        response_pulse(sock, device, c[1])
      else
        sock.write("current not valid\r\n")
      end

    rescue Exception => e
      sock.write("not valid #{e.message}\r\n")
    end
  end



  def self.test
    "aaa"
  end


  def self.response_keep_connect(sock, device, str)
    #TODO: send every 5 minutes
    print "response_keep_connect"
    #TODO
    #1.SG*8800000015*0002*LK
    #2.SG*8800000015*000D*LK,50,100,100
    if str != nil
      fields = str.split(',')
      step_count = fields[0]
      turn_count = fields[1]
      battery_percent = fields[2]
    end
    sock.write("#{HEAD}*#{device}*0002*LK\r\n")
  end

  def self.response_report_geo(sock, device, str)
    #TODO: update geo loc in database
    #geo_status = str.split(',')
    #geo_status
    device_model = Device.find_device(device)
    device_model.add_tracking_record_geo(str)

    sock.write("geo ok!\r\n")
  end

  def self.response_report_geo_2(sock, device, str)
    #TODO: update geo loc in database
    #geo_status = str.split(',')
    #geo_status
    device_model = Device.find_device(device)
    device_model.add_tracking_record_geo(str)

    sock.write("geo2 ok!\r\n")
  end

  def self.response_alarm_data(sock, device, str)
    #TODO: update data in databse
    sock.write("#{HEAD}*#{device}*0002*AL\r\n")
  end

  def self.response_address_data(sock, device, str)
    #Todo: 相应语⾔言地址信息
    fields = str.split(',')
    languange = fields[0]
    case languange
    when 'CH'
      str = "中文"
      str = str.encode("gb2312")
      sock.write("#{HEAD}*#{device}*000C*RAD,GPS,#{str}\r\n")
    when 'EN'
      str = "English"
      str = str.encode("gb2312")
      sock.write("#{HEAD}*#{device}*000C*RAD,GPS,#{str}\r\n")
    else
      sock.write("current not valid\r\n")
    end
  end

  def self.response_lat_lng_data(sock, device, str)
    #Todo: logic
    sock.write("#{HEAD}*#{device}*0021*RG,BASE,22.571707,N,113.8613968,E\r\n")
  end

  #send message

  def self.setup_positive_methods()
    [
      method(:none),
      method(:set_data_upload_interval),
      method(:set_center_number),
      method(:set_assist_center_number),
      method(:set_pw),
      method(:make_call),

      method(:send_sms),
      method(:monitor),
      method(:set_sos_number),
      method(:remote_upgrade),
      method(:set_ip),

      method(:set_factory),
      method(:set_language_time_zone),
      method(:query_google_url),
      method(:set_sos_alarm),
      method(:set_battery_alarm),

      method(:set_apn),
      method(:sms_control),
      method(:query_status),
      method(:query_version),
      method(:reset_client),

      method(:active_gps),
      method(:blue_tooth_control),
      method(:set_work_period),
      method(:set_work_time),
      method(:power_off),

      method(:remove),
      method(:query_pulse)
    ]
  end

  def self.none
    
  end

  def self.setup_params()
    [
      {time: "2001-10-10"},
      {number: "01023456789"},
      {number: "01023456789"},
      {number: "01023456789"},
      {lang: "EN", time_zone: "UTC"},
      {toggle: "0"},
      {toggle: "0"},
      {},
      {},
      {},
      {}
    ]
  end

  #1 数据上传间隔
  def self.set_data_upload_interval(device, params = {})
    command = "UPLOAD," + params[:time].to_s
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  def self.response_data_upload_interval(sock, device, str)
    str = "upload ok"
    sock.write("#{str}\r\n")
  end

  #2 中心号码设置
  def self.set_center_number(device, params = {})
    #params[:number]
    str = compack_command("CENTER", params, [:number])
    send_message_to(device, str)
  end

  def self.response_center_number(sock, device, str)
    str = "center number ok"
    sock.write("#{str}\r\n")
  end

  #3 辅助中心号码
  def self.set_assist_center_number(device, params = {})
    #params[:number]
    str = compack_command("SLAVE", params, [:number])
    send_message_to(device, str)
  end

  def self.response_assist_center_number(sock, device, str)
    str = "slave number ok"
    sock.write("#{str}\r\n")
  end

  #4控制密码
  def self.set_pw(device, params = {})
    str = compack_command("PW", params, [:number])
    send_message_to(device, str)
  end

  def self.response_password(sock, device, str)
    str = 'password ok'
    sock.write("#{str}\r\n")
  end

  #5 拨打电话
  def self.make_call(device, params = {})
    str = compack_command("CALL", params, [:number])
    send_message_to(device, str)
  end

  def self.response_call(sock, device, str)
    str = 'make call ok'
    sock.write("#{str}\r\n")
  end

  #6 发送短信
  def self.send_sms(device, params = {})
    params[:content] = params[:content].encode("gb2312")
    str = compack_command("SMS", params, [:number, :content])
    send_message_to(device, str)
  end

  def self.response_sms(sock, device, str)
    str = "sms ok"
    sock.write("#{str}\r\n")
  end

  #7 监听
  def self.monitor(device, params = {})
    str = "0007*MONITOR"
    send_message_to(device, str)
  end

  def self.response_monitor(sock, device, str)
    str = "monitor ok"
    sock.write("#{str}\r\n")
  end

  #8 SOS中心号码
  def self.set_sos_number(device, params = {})
    type = params[:sos_type].to_i
    case type
    when 1
      str = "0010*SOS1," + params[:sos_number1].to_s
    when 2
      str = "0010*SOS2," + params[:sos_number2].to_s
    when 3
      str = "0010*SOS3," + params[:sos_number3].to_s
    when 0
      str = "0010*SOS," + params[:sos_number_1].to_s + "," + params[:sos_number_2].to_s + "," + params[:sos_number_3].to_s
    end
    device_model = Device.find_by(series_code: device)

    old_sos_info = device_model.get_config_field(:sos)
    sos_info = []
    sos_info[0] =  params[:sos_number1].to_s || old_sos_info[0]
    sos_info[1] =  params[:sos_number2].to_s || old_sos_info[1]
    sos_info[2] =  params[:sos_number3].to_s || old_sos_info[2]
    device_model.set_config_field(:sos, sos_info)

    send_message_to(device, str)  
  end

  def self.response_sos_number(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  #9 远程升级
  def self.remote_upgrade(device, params = {})
    command = "UPGRADE," + params[:url].to_s
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  def self.response_upgrade(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  #10 IP端口升级
  def self.set_ip(device, params = {})
    command = "IP," + params[:ip].to_s
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  #11 出厂设置
  def self.set_factory(device, params = {})
    str = "0007*FACTORY"
    send_message_to(device, str)
  end

  def self.response_factory(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  #12语言和时区设置
  def self.set_language_time_zone(device, params = {})
    command = "LZ," + params[:lang].to_s + "," + params[:time_zone].to_s
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  def self.response_language_time_zone(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  #13 url google link
  def self.query_google_url(device, params = {})
    str = "0003*URL"
    send_message_to(device, str)
  end

  def self.response_google_url(sock, device, str)
    #Todo
    google_url = str
    str = "get google url ok"
    sock.write("#{str}\r\n")
  end

  #14 SOS短信报警
  #toggle: 0 off, 1 on
  def self.set_sos_alarm(device, params = {})
    device_model = Device.find_by(series_code: device)
    old_sms_info = device_model.get_config_field(:SMSSettings)
    old_sms_info[1][:state] = params[:toggle].to_s
    device_model.set_config_field(:SMSSettings, old_sms_info)

    str = "0008*SOSSMS," + params[:toggle].to_s
    send_message_to(device, str)
  end

  def self.response_sos_alarm(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  #15 低电短信报警
  def self.set_battery_alarm(device, params = {})
    device_model = Device.find_by(series_code: device)
    old_sms_info = device_model.get_config_field(:SMSSettings)
    old_sms_info[0][:state] = params[:toggle].to_s
    device_model.set_config_field(:SMSSettings, old_sms_info)

    str = "0008*LOWBAT," + params[:toggle].to_s
    send_message_to(device, str)
  end

  def self.response_battery_alarm(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  # 16 APN 设置
  def self.set_apn(device, params ={})
    command = "APN," + params[:apn_name].to_s + "," + params[:user_name].to_s  + "," + params[:password].to_s  + "," + params[:data].to_s
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  def self.response_apn(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  # 17 短信权限控制
  def self.sms_control(device, params = {})
    str = "0005*ANY," + params[:toggle].to_s
    send_message_to(device, str)  
  end

  def self.response_sms_control(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  #18 手机参数查询
  def self.query_status(device, params = {})
    str = "0002*TS"
    send_message_to(device, str)
  end

  def self.response_status(sock, device, str)
    #Todo mobile status
    status = str
    str = "TS ok"
    sock.write("#{str}\r\n")
  end

  #19 手机版本
  def self.query_version(device, params = {})
    str = "0005*VERNO"
    send_message_to(device, str)
  end

  def self.response_version(sock, device, str)
    #Todo mobile version
    version = str
    str = "VERNO ok"
    sock.write("#{str}\r\n")
  end

  #20 重启
  def self.reset_client(device, params = {})
    str = "0005*RESET"
    send_message_to(device, str)
  end

  def self.response_reset(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  #21 定位指令
  def self.active_gps(device, params = {})
    str = "0002*CR"
    send_message_to(device, str)
  end

  def self.response_active_pos(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  #22 blue tooth
  def self.blue_tooth_control(device, params = {})
    str = "0005*BT," + params[:toggle].to_s
    send_message_to(device, str)  
  end

  def self.response_blue_tooth_control(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  #23 工作时间段设置
  def self.set_work_period(device, params = {})
    command = "WORK," + params[:period].to_s
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  def self.response_work_period(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n") 
  end

  #24 工作时间设置
  def self.set_work_time(device, params = {})
    command = "WORKTIME," + params[:time].to_s
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  def self.response_work_time(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n") 
  end

  #25 关机指令
  def self.power_off(device, params = {})
    str = "0008*POWEROFF"
    send_message_to(device, str)
  end

  def self.response_power_off(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n") 
  end

  #26 取下手环报警开关
  def self.remove(device, params = {})
    str = "0008*REMOVE," + params[:toggle].to_s
    send_message_to(device, str)  
  end

  def self.response_remove(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")  
  end
  #27 查询脉搏
  def self.query_pulse(device, params = {})
    str = "0005*PULSE"
    send_message_to(device, str)
  end

  def self.response_pulse(sock, device, str)
    #Todo pulse get
    pulse = str
    str = "PULSE ok"
    sock.write("#{str}\r\n")
  end

  def self.response_voice_message(sock, device, str)
    #SG*8800000015*2962*TK,1,1,2950,#!AMR
    begin
      str = str.split(",", 4)[3]
      dir = "#{Rails.root}/public/voices/#{device}/receive"
      if !File.directory?(dir)
        FileUtils.mkdir_p(dir)
      end
      time_str = Time.now.strftime("%Y_%m_%d_%H_%M_%S")
      file_name = File.join(dir, "#{time_str}.amr")
      File.open(file_name, "wb") do |file|
        file.write(str)
      end
      sock.write("#{1}\r\n")
    rescue Exception => e
      puts "#{e.message}"
      sock.write("#{0}\r\n")
    end
  end

  private

  def self.concat_message(device, str)
    "#{HEAD}*#{device}*#{str}\r\n"
  end

  def self.send_message_to(device, str)
    sock = $socket_device.key(device)
    if sock
      sock.write(concat_message(device,str))
    end
  end

  def self.format_num16(number)
    number.to_s(16).rjust(4, '0')
  end

  def self.compack_command(str, params = {}, filter = [])
    command = str
    filter.each do |value|
      command += ",#{params[value.to_sym].to_s}"
    end
    len = format_num16(command.length)
    "#{len}*#{command}"
  end

end


#a = [1, 2, 3, 4, 5, 6, 7]
#seed = Random.new
#puts a.shuffle(random: seed.rand(1..100))

#print MessageProcessor.in_command("SG*8800000015*0002*LK")
#print MessageProcessor.in_command("SG*8800000015*000D*LK,50,100,100")
#print MessageProcessor.in_command("SG*8800000015*0087*UD,220414,134652,A,22.571707,N,113.8613968,E,0.1,0.0,100,7,60,90, 1000,50,0000,4,1,460,0,9360,4082,131,9360,4092,148,9360,4091,143,9360,4153,141")