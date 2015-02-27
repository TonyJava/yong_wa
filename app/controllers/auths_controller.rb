class AuthsController < ApplicationController
  def send_captcha
    mobile = params[:mobile]
    mobile_regx = /^0?(13[0-9]|15[012356789]|18[0236789]|14[57])[0-9]{8}$/
    if mobile_regx === mobile
      captcha = Random.new
      session[:captcha] = captcha.rand(1000..9999)
      render :json => {
        msg: "send ok",
        request: "GET/auths/send_captcha",
        code: 10000
      }
    else
      render :json => {
        msg: "send captcha error",
        request: "GET/auts/send_captcha",
        code: 10101
      }    
    end
  end

  def check_captcha
    captcha = params[:captcha]
    if captcha == session[:captcha]
      render :json => {
        msg: "check success",
        request: "POST/auths/send_captcha",
        code: 10000
      }
    else
      render :json => {
        msg: "captcha code error",
        request: "GET/auths/check_captcha",
        code: 10202
      } 
    end
  end

  def register
    password_regx = /^[a-z0-9_-]{6,18}$/ 
  end

  def check_device
  end

  def login
  end

  def reset_password
  end
end
