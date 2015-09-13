class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  #:exception

  include ApplicationHelper

  private

    def require_login_role_0
      if session[:login] == nil
        redirect_to new_admin_login_path
      end
    end

    def require_login_role_1
      if session[:login_role_1] == nil
        redirect_to new_admin_login_path
      end
    end

    def require_login
      if session[:login] == nil && session[:login_role_1] == nil
        redirect_to new_admin_login_path
      end
    end

end
