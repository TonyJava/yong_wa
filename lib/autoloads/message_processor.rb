#coding: utf-8
require "socket"


class MessageProcessor

  HEAD = "SG"
  CONFIG_DESCRIPT = {
    sos: "设置SOS号码",
    monitor: "语音监听",
    workMode: "修改工作模式",
    freeTime: "修改免打扰时段",
    weekendPositioning: "修改周末定位时端段",
    lowPowerWarning: "修改低电告警设置",
    sosWarning: "修改SOS告警设置",
    findWatch: "查找手表",
    closeWatch: "远程关闭手表",
    electronicFence: "修改电子围栏",
    location: "立即定位孩子位置",
    shoot: "一键监拍",
    remindInfo: "配置闹铃信息",
    babyPhoneNumber: "设置宝贝通信录",
    schoolPositioning: "修改上学定位时段",
    electronicFenceOn: "开关电子围栏",
    watch_sosWarning: "sos告警",
    watch_lowPowerWarning: "低电告警",
    watch_electronicFence: "电子围栏告警"
  }

  public

  def initialize(args)
    @@head = "SG"
    @@mid = "8800000015" 
  end

  def self.get_history_descript(data = {})
    infos = []
    CONFIG_DESCRIPT.each do |key, value|
      break if data.class.to_s != "Hash"
      if data[key]
        infos[0] ||= ""
        infos.append(value)
      end
    end
    infos.join("")
  end

  def self.push_command_to_redis(device, command_id, params_str)
    command = {device: device, command_id: command_id, params: params_str}.to_json
    $redis.rpush("commands", command)
  end

  def self.process_device_config(device, params = {})
    device_model = Device.find_by(series_code: device)
    if params[:sos]
      puts "process_device_config: #{params[:sos]}"
      params_str = {sos_type: 0, sos_number1: params[:sos][0], sos_number2: params[:sos][1], sos_number3: params[:sos][2]}.to_s
      push_command_to_redis(device, 8, params_str)
      device_model.set_config_field(:sos, params[:sos])
    end

    if params[:babyPhoneNumber]
      infos = params[:babyPhoneNumber]
      infos_1 = infos[0..19]
      #infos_2 = infos[10..19]
      [infos_1].each_with_index do |info, index|
        next if !info
        messanger_str = info.inject("") { |r, e|
          r += "#{e[:name].encode("gb2312")},#{e[:value]},"
        }
        messanger_str = messanger_str[0..-2]
        params_str = {type: index, messanger_info: messanger_str}.to_s
        push_command_to_redis(device, 36, params_str)
      end
      device_model.set_config_field(:babyPhoneNumber, params[:babyPhoneNumber])
    end

    if params[:monitor]
      #monitor(device, {monitor: params[:monitor]})
      params_str =  {monitor: params[:monitor]}.to_s
      push_command_to_redis(device, 7, params_str)
      device_model.set_config_field(:monitor, params[:monitor])
    end

    if params[:workMode]
      #set_work_mode(device, {work_mode: params[:work_mode]})
      params_str =  {work_mode: params[:workMode]}.to_s
      push_command_to_redis(device, 40, params_str)
      device_model.set_config_field(:workMode, params[:workMode])
    end

    if params[:freeTime]
      #set_free_period(device, {period: params[:freeTime].to_s.delete("[]") } )
      params_str =  {period: params[:freeTime].to_s.delete("[]") }.to_s
      push_command_to_redis(device, 28, params_str)
      device_model.set_config_field(:freeTime, params[:freeTime])
    end

    if params[:weekendPositioning]
      #set_weekend_period(device, {period: params[:weekendPositioning].to_s.delete("[]")})
      params_str = {period: params[:weekendPositioning].to_s.delete("[]") }.to_s
      push_command_to_redis(device, 41, params_str)
      device_model.set_config_field(:weekendPositioning, params[:weekendPositioning])
    end

    if params[:schoolPositioning]
      params_str = {period: params[:schoolPositioning].to_s.delete("[]") }.to_s
      push_command_to_redis(device, 23, params_str)
      device_model.set_config_field(:weekendPositioning, params[:schoolPositioning])
    end

    if params[:lowPowerWarning]
      #set_battery_alarm(device, {toggle: params[:lowPowerWarning]})
      params_str = {toggle: params[:lowPowerWarning]}.to_s
      push_command_to_redis(device, 15, params_str)
      device_model.set_config_field(:lowPowerWarning, params[:lowPowerWarning])
    end

    if params[:sosWarning]
      #set_sos_alarm(device, {toggle: params[:sosWarning]})
      params_str = {toggle: params[:sosWarning]}.to_s
      push_command_to_redis(device, 14, params_str)
      device_model.set_config_field(:sosWarning, params[:sosWarning])
    end

    if params[:findWatch]
      if params[:findWatch].to_i == 1
        #find_watch(device, {})
        params_str = {}.to_s
        push_command_to_redis(device, 29, params_str)
      end
      device_model.set_config_field(:findWatch, params[:findWatch])
    end

    if params[:closeWatch]
      if params[:closeWatch].to_i == 1
        #power_off(device, {})
        params_str = {}.to_s
        push_command_to_redis(device, 25, params_str)
      end
      device_model.set_config_field(:closeWatch, params[:closeWatch])
    end

    if params[:remindInfo]
      params_str = {remind_info: params[:remindInfo].to_s.delete("[]")}.to_s
      push_command_to_redis(device, 32, params_str)
      device_model.set_config_field(:remindInfo, params[:remindInfo])
    end

    if params[:electronicFence]
      device_model.set_config_field(:electronicFence, params[:electronicFence])
    end

    if params[:location]
      if params[:location].to_i == 1
        params_str = {}.to_s
        push_command_to_redis(device, 43, params_str)
      end
      device_model.set_config_field(:location, params[:location])
    end

    if params[:shoot]
      params_str = {shoot: params[:shoot]}.to_s
      push_command_to_redis(device, 42, params_str)
      device_model.set_config_field(:shoot, params[:shoot])
    end

    History.create(device: device_model, data_content: params.to_s)
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

      if device #&& !$socket_device[sock]
        $socket_device[sock] = device
        puts "device: #{device}"
        puts $socket_device if Rails.env == "development"
        puts $socket_device.key(device) if Rails.env == "development"
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
      when 'FIND'
        response_find_watch(sock, device, c[0])
      when 'WORKMODE'
        response_set_work_mode(sock, device, c[0])
      when 'WORK2'
        response_weekend_period(sock, device, c[0])
      when 'PHB'
      when 'PHB2'
        response_set_messanger(sock, device, c[0])
      when 'SILENCETIME'
        response_free_period(sock, device, c[0])
      when 'FLOWER'
        response_set_flower(sock, device, c[0])
      when 'REMIND'
        response_set_remind(sock, device, c[0])
      when 'SHOOT'
        response_shoot(sock, device, c[0])
      when 'LOCATION'
        response_location(sock, device, c[1])
      when 'SOSQ'
        response_sos_number_resuest(sock, device, c[0])
      when 'PHBQ'
        response_messanger_resuest(sock, device, c[0])
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
    #print "response_keep_connect"
    #TODO
    #1.SG*8800000015*0002*LK
    #步数 翻滚次数 电量 运动距离 运动量 开启关闭
    #2.SG*8800000015*000D*LK,50,100,100,100,100,1
    device_model = Device.find_device(device)
    if str != nil && device_model
      fields = str.split(',')
      step_count = fields[0].to_i
      turn_count = fields[1].to_i
      battery_percent = fields[2].to_i
      move_distance = fields[3].to_i
      move_calorie = fields[4].to_i
      toggle = fields[5]

      date_str = DateString.today
      if toggle.to_s == "1"
        device_model.set_health_info_extra(date_str, 
          {
            step_extra: step_count,
            turn_extra: turn_count,
            move_distance_extra: move_distance,
            move_calorie_extra: move_calorie
          }
        )
      elsif toggle.to_s == "0"
        device_model.add_health_info_zero_count(date_str, 
          {
            step_zero_count: step_count,
            turn_zero_count: turn_count,
            move_distance_zero_count: move_distance,
            move_calorie_zero_count: move_calorie
          }
        )
      end
    end
    current_time = DateString.now
    response = "LK,#{current_time}"
    len = format_num16(response.length)
    str = "#{len}*#{response}"
    send_message_to(device, str)
  end

  def self.response_report_geo(sock, device, str)
    #TODO: update geo loc in database
    #geo_status = str.split(',')
    #geo_status
    device_model = Device.find_device(device)
    if device_model
      device_model.add_tracking_record_geo(str)
    end    
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
    device_model = Device.find_device(device)
    params = {}
    type = str.split(",", 2)[0]
    data_content = str.split(",", 2)[1]
    case type
    when "1"
      params[:watch_lowPowerWarning] = "1"
    when "2"
      params[:watch_electronicFence] = "1"
    when "3"
      params[:watch_sosWarning] = "1"
    end
    params[:watch_data] = data_content
    History.create(device: device_model, data_content: params.to_s)
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

  def self.response_sos_number_resuest(sock, device, str)
    device_model = Device.find_by(series_code: device)
    sos_info = device_model.get_config_field(:sos)
    sos_info ||= []
    command = "SOS," + [sos_info[0], sos_info[1], sos_info[2]].join(",")  
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)  
  end

  def self.response_messanger_resuest(sock, device, str)
    device_model = Device.find_by(series_code: device)
    infos = device_model.get_config_field("babyPhoneNumber")
    #infos_1 = infos[0..9]
    #infos_2 = infos[10..19]
    infos_3 = infos[0..19]
    head_str = ["PHB,", "PHB2,"]
    [infos_3].each_with_index do |info, index|
      next if !info
      messanger_str = info.inject("") { |r, e|
        r += "#{e[:name].encode("gb2312")},#{e[:value]},"
      }
      messanger_str = messanger_str[0..-2]
      command = "#{head_str[index]}" + messanger_str
      len = format_num16(command.length)
      str = "#{len}*#{command}"
      send_message_to(device, str)
    end
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
      #26
      method(:remove),
      method(:query_pulse),
      method(:set_free_period),
      method(:find_watch),
      method(:set_flower),
      #31
      method(:none),
      method(:set_remind),
      method(:none),
      method(:none),
      method(:none),
      #36
      method(:set_messanger),
      method(:send_voice_message),
      method(:none),
      method(:none),
      method(:set_work_mode),
      #41
      method(:set_weekend_period),
      method(:shoot),
      method(:location)
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
    puts params
    type = params[:sos_type].to_i
    command = ""
    case type
    when 1
      command = "SOS1," + params[:sos_number1].to_s
    when 2
      command = "SOS2," + params[:sos_number2].to_s
    when 3
      command = "SOS3," + params[:sos_number3].to_s
    when 0
      command = "SOS," + params[:sos_number1].to_s + "," + params[:sos_number2].to_s + "," + params[:sos_number3].to_s
    end
    len = format_num16(command.length)
    str = "#{len}*#{command}"

    device_model = Device.find_by(series_code: device)

    old_sos_info = device_model.get_config_field(:sos)
    sos_info = []
    sos_info[0] =  params[:sos_number1] || old_sos_info[0]
    sos_info[1] =  params[:sos_number2] || old_sos_info[1]
    sos_info[2] =  params[:sos_number3] || old_sos_info[2]
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
    # device_model = Device.find_by(series_code: device)
    # old_sms_info = device_model.get_config_field(:SMSSettings)
    # old_sms_info[1][:state] = params[:toggle].to_s
    # device_model.set_config_field(:SMSSettings, old_sms_info)

    str = "0008*SOSSMS," + params[:toggle].to_s
    send_message_to(device, str)
  end

  def self.response_sos_alarm(sock, device, str)
    #str = "#{str} ok"
    #sock.write("#{str}\r\n")
  end

  #15 低电短信报警
  def self.set_battery_alarm(device, params = {})
    # device_model = Device.find_by(series_code: device)
    # old_sms_info = device_model.get_config_field(:SMSSettings)
    # old_sms_info[0][:state] = params[:toggle].to_s
    # device_model.set_config_field(:SMSSettings, old_sms_info)

    str = "0008*LOWBAT," + params[:toggle].to_s
    send_message_to(device, str)
  end

  def self.response_battery_alarm(sock, device, str)
    #str = "#{str} ok"
    #sock.write("#{str}\r\n")
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

  #26 
  def self.remove(device, params = {})
    str = "0008*REMOVE," + params[:toggle].to_s
    send_message_to(device, str)  
  end

  def self.response_remove(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")  
  end
  #27 
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

  #28 
  def self.set_free_period(device, params = [])
    command = "SILENCETIME," + params[:period].to_s
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  def self.response_free_period(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n") 
  end

  #29 
  def self.find_watch(device, params = {})
    str = "0004*FIND"
    send_message_to(device, str)
  end

  def self.response_find_watch(sock, device, str)
    str = "FIND ok"
    sock.write("#{str}\r\n")
  end

  #30

  def self.set_flower(device, params = {})
    str = "0008*FLOWER," + params[:flower].to_s
    send_message_to(device, str)
  end 

  def self.response_set_flower(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n") 
  end

  #32 alarm
  def self.set_remind(device, params = {})
    command = "REMIND," + params[:remind_info].to_s
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  def self.response_set_remind(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n") 
  end

  #36 messanger
  def self.set_messanger(device, params = {})
    case params[:type].to_i
    when 0
      command = "PHB," + params[:messanger_info].to_s
    when 1
      command = "PHB2," + params[:messanger_info].to_s
    end
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  def self.response_set_messanger(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end


  #37 voice
  def self.send_voice_message(device, params = {})
    begin
      file_name = params[:file_name]
      file_size = File.size(file_name)
      chunk_size = 1024
      i = 0
      File.open(file_name, 'rb') do |file|
        chunk_count = (file_size * 1.0 / chunk_size).ceil
        while chunk = file.read(chunk_size)
          #sock.write("a")
          #{}"sock.write("#{chunk.size} ")
          i += 1
          #chunk.gsub!("\r","\r#{extra_r}")
          #chunk.gsub!("\n","\n#{extra_n}")
          command = "TK,#{File.basename(file_name)},#{i},#{chunk_count},#{chunk}"
          len = format_num16(command.length)
          str = "#{len}*#{command}"
          send_message_to(device, str)
          sleep(1.0)
        end
      end
    rescue Exception => e
      puts "#{e.inspect}"
    end

  end

  def self.response_voice_message(sock, device, str)
    #SG*8800000015*2962*TK,file_name,1,2,#!AMR
    begin
      #str = str.force_encoding("utf-8")
      #response of client has received file from server 
      if str == nil
        str = "TK ok"
        sock.write("#{str}\r\n")
        return 
      end
      content = str.split(",", 4)[3]
      #time_str = Time.now.strftime("%Y_%m_%d_%H_%M_%S")
      time_str = str.split(",", 4)[0]

      part = str.split(",", 4)[1].to_i
      total = str.split(",", 4)[2].to_i

      device_model = Device.find_device(device)
      user_devices = UserDevice.where(device: device_model)

      if part == 1
        mode = "wb"
      else
        mode = "ab"
      end

      user_devices.each do |user_device|
        dir = "#{Rails.root}/public/voices/#{device}/#{user_device.user.mobile}"
        if !File.directory?(dir)
          FileUtils.mkdir_p(dir)
        end
        file_name = File.join(dir,"#{time_str}_receive.amr_temp")

        File.open(file_name, mode) do |file|
          file.write(content)
          file.close      
          if part == total
            complete_name = File.join(dir,"#{time_str}_receive.amr")
            FileUtils.mv file, complete_name
          end
        end

      end

      response = "TK,1"
      len = format_num16(response.length)
      str = "#{len}*#{response}"
      send_message_to(device, str)
    rescue Exception => e
      puts "#{e.inspect}"
      puts e.backtrace.join("\n")
      response = "TK,0"
      len = format_num16(response.length)
      str = "#{len}*#{response}"
      send_message_to(device, str)
    end
  end


  #40 work mode
  def self.set_work_mode(device, params = {})
    str = "0010*WORKMODE," + params[:work_mode].to_s
    send_message_to(device, str)
  end

  def self.response_set_work_mode(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n")
  end

  #41 weekend
  def self.set_weekend_period(device, params = {})
    command = "WORK2," + params[:period].to_s
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  def self.response_weekend_period(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n") 
  end

  # 42 shoot
  def self.shoot(device, params = {})
    command = "SHOOT," + params[:shoot].to_s
    len = format_num16(command.length)
    str = "#{len}*#{command}"
    send_message_to(device, str)
  end

  def self.response_shoot(sock, device, str)
    str = "#{str} ok"
    sock.write("#{str}\r\n") 
  end

  #43 location
  def self.location(device, params = {})
    str = "0008*LOCATION"
    send_message_to(device, str)
  end

  def self.response_location(sock, device, str)
    device_model = Device.find_device(device)
    if device_model
      device_model.add_tracking_record_geo(str)
    end
    sock.write("location ok!\r\n")
  end

  private

  def self.concat_message(device, str)
    "#{HEAD}*#{device}*#{str}\r\n"
  end

  def self.send_message_to(device, str)
    sock = $socket_device.key(device)
    if sock
      sock.write(concat_message(device,str))
    else
      puts "device not exist"
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