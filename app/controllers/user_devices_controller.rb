class UserDevicesController < ApplicationController
  before_action :set_user_device, only: [:show, :edit, :update, :destroy]

  # GET /user_devices
  # GET /user_devices.json
  def index
    @user_devices = UserDevice.all
  end

  # GET /user_devices/1
  # GET /user_devices/1.json
  def show
  end

  # GET /user_devices/new
  def new
    @user_device = UserDevice.new
  end

  # GET /user_devices/1/edit
  def edit
  end

  # POST /user_devices
  # POST /user_devices.json
  def create
    @user_device = UserDevice.new(user_device_params)

    respond_to do |format|
      if @user_device.save
        format.html { redirect_to @user_device, notice: 'User device was successfully created.' }
        format.json { render :show, status: :created, location: @user_device }
      else
        format.html { render :new }
        format.json { render json: @user_device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_devices/1
  # PATCH/PUT /user_devices/1.json
  def update
    respond_to do |format|
      if @user_device.update(user_device_params)
        format.html { redirect_to @user_device, notice: 'User device was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_device }
      else
        format.html { render :edit }
        format.json { render json: @user_device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_devices/1
  # DELETE /user_devices/1.json
  def destroy
    @user_device.destroy
    respond_to do |format|
      format.html { redirect_to user_devices_url, notice: 'User device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_device
      @user_device = UserDevice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_device_params
      params.require(:user_device).permit(:user_id, :device_id)
    end
end
