class Admin::LoginsController < ApplicationController
  def new
    if session[:login] != nil
      redirect_to users_path
    else
      @admin_manage_user = Admin::ManageUser.new
      render :new
    end
  end

  def create
    @admin_manage_user = Admin::ManageUser.new(user_params)
    if @admin_manage_user.registered?
      session[:login] = @admin_manage_user.id
      redirect_to users_path
    else
      render :new
    end
  end

  def destroy
    session[:login] = nil
    redirect_to new_admin_login_path
  end

  def activate_socket
    if request.xhr?
      if ResqueSocket.is_port_open?
        Resque.enqueue(ResqueSocket)
      end
      
      render json: {
        active: !ResqueSocket.is_port_open?
      }
    end
  end

  private
    def user_params
      params.require(:admin_manage_user).permit(:user_name,:password)
    end

end
