require "socket"




class MessageProcessor

  HEAD = "SG"
  @@sides = 10

  public

  def initialize(args)
    @@head = "SG"
    @@mid = "8800000015" 
  end

  def self.get_sides
    @@sides
  end
  

  # receive message
  def self.in_command(sock, str)
    #a = /(.)\*/.match(str)
    str = str.strip
    #binding.pry
    begin
      a = str.split('*')
      device = a[1]

      if device && !$socket_device[sock]
        $socket_device[sock] = device
        puts "connect new device: #{device}"
      end

      b = a[3]
      c = b.split(',', 2)
      case c[0]
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
    geo_status = str.split(',')
    geo_status
    sock.write("geo ok!\r\n")
  end

  def self.response_report_geo_2(sock, device, str)
    #TODO: update geo loc in database
    geo_status = str.split(',')
    geo_status
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
      sock.write("#{HEAD}*#{device}*000C*RAD,GPS,中文\r\n")
    when 'EN'
      sock.write("#{HEAD}*#{device}*000C*RAD,GPS,English\r\n")
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
      method(:set_data_upload_interval),
      method(:set_center_number),
      method(:set_assist_center_number),
      method(:set_sos_number),
      method(:set_language_time_zone),
      method(:set_sos_alarm),
      method(:set_battery_alarm),
      method(:query_status),
      method(:query_version),
      method(:reset_client),
      method(:active_gps)
    ]
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

  #数据上传间隔
  def self.set_data_upload_interval(device, params = {})
    str = "0009*" + params[:time].to_s
    send_message_to(device, str)
  end

  #中心号码设置
  def self.set_center_number(device, params = {})
    str = "0012*CENTER," + params[:number].to_s
    send_message_to(device, str)
  end

  #辅助中心号码
  def self.set_assist_center_number(device, params = {})
    str = "0011*SLAVE," + params[:number].to_s
    send_message_to(device, str)
  end

  #SOS中心号码
  def self.set_sos_number(device, params = {})
    str = "0010*SOS1," + params[:number].to_s
    send_message_to(device, str)  
  end

  #语言和时区设置
  def self.set_language_time_zone(device, params = {})
    str = "0006*LZ," + params[:lang].to_s + "," + params[:time_zone].to_s
    send_message_to(device, str)
  end

  #SOS短信报警
  #toggle: 0 off, 1 on
  def self.set_sos_alarm(device, params = {})
    str = "0008*SOSSMS," + params[:toggle].to_s
    send_message_to(device, str)
  end
  #低电短信报警
  def self.set_battery_alarm(device, params = {})
    str = "0008*LOWBAT," + params[:toggle].to_s
    send_message_to(device, str)
  end

  #手机参数
  def self.query_status(device, params = {})
    str = "0002*TS"
    send_message_to(device, str)
  end

  #手机版本
  def self.query_version(device, params = {})
    str = "0005*VERNO"
    send_message_to(device, str)
  end

  #重启
  def self.reset_client(device, params = {})
    str = "0005*RESET"
    send_message_to(device, str)
  end

  #定位指令
  def self.active_gps(device, params = {})
    str = "0002*CR"
    send_message_to(device, str)
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

end


#a = [1, 2, 3, 4, 5, 6, 7]
#seed = Random.new
#puts a.shuffle(random: seed.rand(1..100))

#print MessageProcessor.in_command("SG*8800000015*0002*LK")
#print MessageProcessor.in_command("SG*8800000015*000D*LK,50,100,100")
#print MessageProcessor.in_command("SG*8800000015*0087*UD,220414,134652,A,22.571707,N,113.8613968,E,0.1,0.0,100,7,60,90, 1000,50,0000,4,1,460,0,9360,4082,131,9360,4092,148,9360,4091,143,9360,4153,141")