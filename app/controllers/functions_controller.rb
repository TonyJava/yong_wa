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
        }
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

      render :json => {
        msg: "update device ok",
        request: "POST/functions/update_device",
        code: 10000
      }
    end

  end

  def show_history

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
      histories = History.where(device: device)
      
    end
  end

  def send_command
  end
end
