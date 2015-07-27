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
    str = str.strip
    #binding.pry
    begin
      a = str.split('*')
      device = a[1]
      b = a[3]
      c = b.split(',')
      case c[0]
      when 'LK'
        response_keep_connect(sock, device)
      when 'UD'
        response_report_geo(sock, device, c[1])
      when 'AL'
        response_alarm_data(sock, device, c[1])
      end

    rescue Exception => e
      sock.write("not valid\r\n")
    end
  end

  def self.test
    "aaa"
  end


  def self.response_keep_connect(sock, device)
    #TODO: send every 5 minutes
    print "response_keep_connect"
    sock.write("#{HEAD}*#{device}*0002*LK\r\n")
  end

  def self.response_report_geo(sock, device, str)
    #TODO: update geo loc in database
    geo_status = str.split(',')
    geo_status
    sock.write("geo ok!\r\n")
  end

  def self.response_alarm_data(sock, device, str)
    #TODO: update data in databse
    sock.write("#{head}*#{device}*0002*AL\r\n")
  end

  #send message

  #数据上传间隔
  def self.set_data_upload_interval(sock, time)
    str = "0009*" + time.to_s
    sock.write(concat_message(str))
  end

  #中心号码设置
  def self.set_center_number(sock, number)
    str = "0012*CENTER," + number.to_s
    sock.write(concat_message(str))
  end

  #辅助中心号码
  def self.set_assist_center_number(sock, number)
    str = "0011*SLAVE," + number.to_s
    sock.write(concat_message(str))
  end

  #SOS中心号码
  def self.set_sos_number(sock, number)
    str = "0010*SOS1," + number.to_s
    sock.write(concat_message(str))
  end

  #语言和时区设置
  def self.set_language_time_zone(sock, lang, time_zone)
    str = "0006*LZ," + lang.to_s + "," + time_zone.to_s
    sock.write(concat_message(str))
  end

  #SOS短信报警
  #toggle: 0 off, 1 on
  def self.set_sos_alarm(toggle)
    str = "0008*SOSSMS," + toggle.to_s
    sock.write(concat_message(str))
  end
  #低电短信报警
  def self.set_battery_alarm(toggle)
    str = "0008*LOWBAT," + toggle.to_s
    sock.write(concat_message(str))
  end

  #手机参数
  def self.query_status()
    str = "0002*TS"
    sock.write(concat_message(str))
  end

  #手机版本
  def self.query_version()
    str = "0005*VERNO"
    sock.write(concat_message(str))
  end

  #重启
  def self.reset_client()
    str = "0005*RESET"
    sock.write(concat_message(str))
  end

  #定位指令
  def self.active_gps()
    str = "0002*CR"
    sock.write(concat_message(str))
  end

  private

  def concat_message(str)
    "#{@@head}*#{@@mid}*#{str}\r\n"
  end

end


#a = [1, 2, 3, 4, 5, 6, 7]
#seed = Random.new
#puts a.shuffle(random: seed.rand(1..100))

#print MessageProcessor.in_command("SG*8800000015*0002*LK")
#print MessageProcessor.in_command("SG*8800000015*000D*LK,50,100,100")
#print MessageProcessor.in_command("SG*8800000015*0087*UD,220414,134652,A,22.571707,N,113.8613968,E,0.1,0.0,100,7,60,90, 1000,50,0000,4,1,460,0,9360,4082,131,9360,4092,148,9360,4091,143,9360,4153,141")