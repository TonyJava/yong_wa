class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy]
  before_action :require_login_role_0, only: [:edit, :destroy]
  before_action :require_login_role_1, only: [:reset_page]
  before_action :require_login, only: [:reset, :show, :update]
  # GET /devices
  # GET /devices.json
  def index
    @devices = Device.all.page(params[:page])
    @device = Device.new
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
    @login_role = 1 if session[:login_role_1] != nil
    @login_role = 0 if session[:login] != nil
  end

  # GET /devices/new
  def new
    @device = Device.new
  end

  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  # POST /devices.json
  def create
    @device = Device.new(device_params)

    respond_to do |format|
      if @device.save
        format.html { redirect_to @device, notice: 'Device was successfully created.' }
        format.json { render :show, status: :created, location: @device }
      else
        format.html { render :new }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  def reset_page
  end

  def reset
    @device = Device.find_device(device_params[:series_code])
    @device.reset
    redirect_to @device, notice: 'Device was successfully reset.'
  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update
    respond_to do |format|
      if @device.update(device_params)
        format.html { redirect_to @device, notice: 'Device was successfully updated.' }
        format.json { render :show, status: :ok, location: @device }
      else
        format.html { render :edit }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @device.destroy
    respond_to do |format|
      format.html { redirect_to devices_url, notice: 'Device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(:series_code, :active, :config_info, :mobile)
    end
end
