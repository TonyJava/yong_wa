class FunctionsController < ApplicationController



  def show_device
    device = Device.find_by(series_code: params[:device])
    if !User.token_valid?(params[:token])
      render :json => {
        msg: "show device code error",
        request: "POST/functions/show_device",
        code: 20101
      }
    elsif device == nil
      render :json => {
        msg: "show device code error",
        request: "POST/functions/show_device",
        code: 20102
      }
    else
      render :json => {
        msg: "show device ok",
        request: "POST/functions/show_device",
        code: 10000,
        device_info: {
          device_id: device.series_code,
          device_name: device.device_name || device.series_code ,
          sex: device.sex,
          birth: device.birth,
          height: device.height,
          weight: device.weight,
          mobile: device.mobile,
          imei: device.imei
        },
        device_config: device.get_config
      }
    end

  end

  def update_device
    device = Device.find_by(series_code: params[:device])
    if !User.token_valid?(params[:token])
      render :json => {
        msg: "update device code error",
        request: "POST/functions/update_device",
        code: 20201
      }
    elsif device == nil
      render :json => {
        msg: "update device code error",
        request: "POST/functions/update_device",
        code: 20202
      }
    else

      device.device_name = params[:device_name] unless params[:device_name] == nil
      device.sex = params[:sex] unless params[:sex] == nil
      device.birth = params[:birth] unless params[:birth] == nil
      device.height = params[:height] unless params[:height] == nil
      device.weight = params[:weight] unless params[:weight] == nil
      device.mobile = params[:mobile] unless params[:mobile] == nil
      device.imei = params[:imei] unless params[:imei] == nil
      device.save!

      render :json => {
        msg: "update device ok",
        request: "POST/functions/update_device",
        code: 10000
      }
    end

  end

  def show_tracking
    device = Device.find_by(series_code: params[:deviceId])
    if !User.token_valid?(params[:token])
      render :json => {
        msg: "show tracking code error",
        request: "POST/functions/show_tracking",
        code: 0
      }
    elsif device == nil
      render :json => {
        msg: "show tracking code error",
        request: "POST/functions/show_tracking",
        code: 0
      }
    else
      render :json => {
        msg: "show tracking ok",
        request: "POST/functions/show_tracking",
        code: 1,
        data: device.get_tracking_record(params[:begin], params[:end])
      }
    end
  end

  def show_history
    device = Device.find_by(series_code: params[:device])
    if Rails.env == "production" && !User.token_valid?(params[:token])
      render :json => {
        msg: "show history code error",
        request: "POST/functions/show_history",
        code: 20301
      }
    elsif device == nil
      render :json => {
        msg: "show history code error",
        request: "POST/functions/show_history",
        code: 20302
      }
    else
      perpage_count = params[:record_limit].to_i
      histories = History.where(device: device).order("created_at DESC")
      total_count = histories.count

      max_page = total_count / perpage_count
      max_page += 1 if total_count % perpage_count >= 1

      view_page = params[:page_num].to_i
      page_offset = perpage_count * (view_page - 1)
      histories = histories.limit(perpage_count).offset(page_offset)
      data_count = histories.count

      hash_data = {}
      hash_data[:data] = []
      data_count.times do |i|
        history = histories[i]
        data_content = history.data_content != nil ? eval(history.data_content) : ""
        hash_data[:data].append({
          device: device.series_code,
          data_type: history.data_type,
          data_description: MessageProcessor.get_history_descript(data_content),
          data_content: data_content,
          time_stamp: history.created_at.to_s,
          location_code: history.location_code,
          location_type: history.location_type,
          data_stamp_address: history.data_stamp_address
        })
      end

      render :json => hash_data.merge({
        msg: "show history ok",
        request: "POST/functions/show_history",
        code: 10000,
        data_count: data_count,
        max_page: max_page
      })
    end

  end

  def send_command
    device = Device.find_by(series_code: params[:device])
    if !User.token_valid?(params[:token])
      render :json => {
        msg: "send command code error",
        request: "POST/functions/send_command",
        code: 20401
      }
    elsif device == nil
      render :json => {
        msg: "send command code error",
        request: "POST/functions/send_command",
        code: 20402
      }
    elsif (params[:command_info] == nil)
      render :json => {
        msg: "send command code error",
        request: "POST/functions/send_command",
        code: 20403
      }
    else

      command_id = params[:command_info].to_i
      params_str = params[:params_str]
      command = {device: device.series_code, command_id: command_id, params: params_str}.to_json
      $redis.rpush("commands", command)

      history = History.new(device: device)
      history.save!

      render :json => {
        msg: "send command ok",
        request: "POST/functions/send_command",
        code: 10000
      }
    end

  end

  def update_device_config
    device = Device.find_by(series_code: params[:deviceId])
    if Rails.env == "production" && !User.token_valid?(params[:token])
      render :json => {
        msg: "send command code error not valid token",
        request: "POST/functions/update_device_config",
        code: 0
      }
    elsif device == nil
      render :json => {
        msg: "send command code error not valid device",
        request: "POST/functions/update_device_config",
        code: 0
      }
    else
      MessageProcessor.process_device_config(params[:deviceId], params)
      render :json => {
        msg: "update device config ok",
        request: "POST/functions/update_device_config",
        code: 10000
      }
    end
  end

  def get_storyInfo
    if User.token_valid?(params[:token])
      path = File.expand_path('public/Bobdog.xml', Rails.root)
      file = File.read(path)
      render json: {
        code: 2,
        msg: "success",
        data: Hash.from_xml(file).to_json
      }
    else
      render json: {
        code: 0,
        msg: "invalid token",
        data: nil
      }
    end
  end

  def get_userInfo
    user = User.find_by(mobile: params[:mobile], auth_token: params[:token])
    if !user
      msg = User.token_valid?(params[:token]) ? "user is not existed" : "token is not valid"
      render :json => {
        msg: msg,
        request: "POST/functions/get_userInfo",
        code: 0,
        data: nil
      }
    else
      devices_info = []
      devices = user.user_device
      devices.each do |d|
        devices_info << {deviceId: d.device.series_code, state: d.device.active == true, deviceName: d.device.device_name || d.device.series_code, deviceMobile: d.device.mobile}
      end
      render :json => {
        msg: "success",
        request: "POST/functions/get_userInfo",
        code: 1,
        data: {
          personInfo: {
            name: user.mobile,
            mobile: user.mobile,
            password: user.password
          },
          devices: devices_info
        }
      }
    end
  end
  # deviceId <-> devicemobile
  def activate_device
    device = Device.find_by(series_code: params[:deviceId])
    if !Device.exist?(params[:deviceId])
      render :json => {
        msg: "device not exist",
        request: "POST/functions/activate_device",
        code: 0
      }   
    else
      error = send_server_info_to_watch(params[:devicemobile])
      if error.to_i == 0
        device.update(mobile: params[:devicemobile], active: true)
        render :json => {
          msg: "activate device ok",
          request: "POST/functions/activate_device",
          code: 1
        }
      else
        render :json => {
          msg: "send message to device fail",
          request: "POST/functions/activate_device",
          code: 0
        }
      end
    end
  end

  # user <-> device
  def bind_device
    user = User.find_by(mobile: params[:mobile], auth_token: params[:token])
    device = Device.find_by(series_code: params[:deviceId])
    if !user && Rails.env == "production"
      msg = User.token_valid?(params[:token]) ? "user is not existed" : "token is not valid"
      render :json => {
        msg: msg,
        request: "POST/functions/bind_device",
        code: 0
      }
    elsif !device
      render :json => {
        msg: "device not exist",
        request: "POST/functions/bind_device",
        code: 0
      }
    else

      if UserDevice.find_by(device: device) == nil
        user_device = UserDevice.new(user: user, device: device)
        user_device.save!
        render :json => {
          msg: "bind_device ok",
          request: "POST/functions/bind_device",
          code: 1
        }
      else
        render :json => {
          msg: "device already binded",
          request: "POST/functions/bind_device",
          code: 0
        }
      end

    end
  end

  def baby_health_info
    user = User.find_by(mobile: params[:mobile], auth_token: params[:token])
    device = Device.find_by(series_code: params[:device])
    if !user
      msg = User.token_valid?(params[:token]) ? "user is not existed" : "token is not valid"
      render :json => {
        msg: msg,
        request: "POST/functions/baby_health_info",
        code: 0,
        data: nil
      }
    elsif !device
      msg = "device is not existed"
      render :json => {
        msg: msg,
        request: "POST/functions/baby_health_info",
        code: 0,
        data: nil
      }
    else
      result = device.get_health_info(params[:beginTime], params[:endTime])
      render :json => {
        msg: msg,
        request: "POST/functions/baby_health_info",
        code: 1,
        data: result
      }
    end
  end

  def flower_reward
    user = User.find_by(mobile: params[:mobile], auth_token: params[:token])
    device = Device.find_by(series_code: params[:device])
    if !user
      msg = User.token_valid?(params[:token]) ? "user is not existed" : "token is not valid"
      render :json => {
        msg: msg,
        request: "POST/functions/flower_reward",
        code: 0,
        data: nil
      }
    elsif !device
      msg = "device is not existed"
      render :json => {
        msg: msg,
        request: "POST/functions/flower_reward",
        code: 0,
        data: nil
      }
    else
      params_str = {flower: params[:flower]}.to_s
      MessageProcessor.push_command_to_redis(params[:device], 30, params_str)
      render :json => {
        msg: "flower_reward ok",
        request: "POST/functions/flower_reward",
        code: 1
      }

    end
  end

  def send_voice_file
    device = params[:deviceId]
    begin
      dir = "public/voices/#{device}/#{params[:mobile]}"
      if !File.directory?(dir)
        FileUtils.mkdir_p(dir)
      end
      time_str = Time.now.strftime("%Y_%m_%d_%H_%M_%S")
      file_name = File.join(dir,"#{time_str}_send.amr")
      #multipart
      uploaded_io = params[:voice]
      File.open(file_name, "wb") do |file|
        file.write(uploaded_io.read)
      end

      #MessageProcessor.send_voice_message(params[:deviceId], {file_name: file_name})
      params_str = {file_name: file_name}.to_s
      MessageProcessor.push_command_to_redis(device, 37, params_str)

      render :json => {
        msg: "upload file ok",
        request: "POST/functions/send_voice_file",
        code: 1,
        file_name: file_name
      }
    rescue Exception => e
      render :json => {
        msg: e.message,
        request: "POST/functions/send_voice_file",
        code: 0
      }
    end

  end

  def voice_file_list
    device = params[:deviceId]
    begin
      dir = "public/voices/#{device}/#{params[:mobile]}"
      if !File.directory?(dir)
        FileUtils.mkdir_p(dir)
      end

      total_count = 0
      sorted_files = Dir.glob("#{dir}/*.amr").sort_by { |file|
        total_count += 1
        Time.now - File.mtime(file)
      }

      perpage_count = params[:record_limit].to_i
      max_page = total_count / perpage_count
      max_page += 1 if total_count % perpage_count >= 1
      view_page = [params[:page_num].to_i, max_page].min
      page_offset = perpage_count * (view_page - 1)

      hash_data = {data: []}
      select_files = sorted_files.slice(page_offset, perpage_count)
      select_files.each do |file|
        file_name = File.basename(file, ".amr")
        hash_data[:data].append({
          url:  "voices/#{device}/#{params[:mobile]}/#{file_name}.amr",
          time: File.mtime(file).strftime("%Y-%m-%d %H:%M"),
          type: file_name.split("_")[-1] == "send" ? "send" : "receive"
        })
      end

      render :json => hash_data.merge({
        msg: "voice file list ok",
        request: "GET/functions/voice_file_list",
        code: 1,
        data_count: select_files.count,
        max_page: max_page
      })

    rescue Exception => e
      puts "#{e.inspect}"
      render :json => {
        msg: e.message,
        request: "GET/functions/voice_file_list",
        code: 0
      }
    end
  end

  def play_voice_file
    if !User.token_valid?(params[:token]) && Rails.env == "production"
      render :json => {
        msg: "show device code error",
        request: "POST/functions/show_device",
        code: 20101
      }
      return
    else
      file_path = "public/#{params[:url]}"
      send_file file_path
    end
  end

end
