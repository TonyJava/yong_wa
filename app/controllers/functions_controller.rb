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
          device_name: device.device_name,
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
    device = Device.find_by(series_code: params[:device])
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
    if !User.token_valid?(params[:token])
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
      histories = History.where(device: device).order(:created_at)
      total_count = histories.count

      max_page = total_count / perpage_count
      max_page += 1 if total_count % perpage_count >= 1

      view_page = [params[:page_num].to_i, max_page].min
      page_offset = perpage_count * (view_page - 1)
      histories = histories.limit(perpage_count).offset(page_offset)
      data_count = histories.count

      hash_data = {}
      data_count.times do |i|
        history = histories[i]
        hash_data["data_info#{i}"] = {
          device: device.series_code,
          data_type: history.data_type,
          data_content: history.data_content,
          time_stamp: history.created_at.to_s,
          location_code: history.location_code,
          location_type: history.location_type,
          data_stamp_address: history.data_stamp_address
        }
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
        devices_info << {deviceId: d.device.series_code, state: d.device.active == true}
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
  # deviceid <-> devicemobile
  def activate_device
    device = Device.find_by(series_code: params[:deviceid])
    if !Device.exist?(params[:deviceid])
      render :json => {
        msg: "device not exist",
        request: "POST/functions/activate_device",
        code: 0
      }   
    else
      error = send_server_info_to_watch(params[:devicemobile])
      if error.to_i == 0
        device.update(mobile: params[:devicemobile])
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
    if !user
      msg = User.token_valid?(params[:token]) ? "user is not existed" : "token is not valid"
      render :json => {
        msg: msg,
        request: "POST/functions/bind_device",
        code: 0
      }
    else
      device = Device.find_by(series_code: params[:deviceid])
      user_device = UserDevice.new(user: user, device: device)
      user_device.save!

      render :json => {
        msg: "bind_device ok",
        request: "POST/functions/bind_device",
        code: 1
      }
    end
  end

end
