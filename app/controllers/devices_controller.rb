# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_device, only: [:show, :edit, :update, :destroy]

  def index
    # @mhz19b = JSON.parse RestClient.get('krsz.ru:3004/mhz19b')
    # @bme280 = JSON.parse RestClient.get('krsz.ru:3004/bme280')
    # @gpio   = JSON.parse RestClient.get('krsz.ru:3004/pins')
    @devices = current_user.devices.eager_load(:capabilities).sort
  end

  def show; end

  def new
    @device = current_user.devices.new
  end

  def edit; end

  def create
    @device = current_user.devices.new(device_params)

    if @device.save
      redirect_to devices_url, notice: 'Устройство создано!'
    else
      render :new
    end
  end

  def update
    if @device.update(device_params)
      redirect_to devices_url, notice: 'Устройство обновлено!'
    else
      render :edit
    end
  end

  def destroy
    @device.destroy
    redirect_to devices_url, notice: 'Устройство удалено!'
  end

  def drivent
    client = MQTT::Client.connect(ENV['MQTT_HOST'], port: ENV['MQTT_PORT'], username: ENV['MQTT_USER'], password: ENV['MQTT_PASS'])
    client.publish("#{params[:name]}/setTargetPosition", params[:percent], true)
    client.disconnect
    render json: {name: params[:name], percent: params[:percent]}
  end

  private

  def set_device
    @device = current_user.devices.find(params[:id])
  end

  def device_params
    params.require(:device)
          .permit(:enabled, :name, :description, :room, :device_type, :manufacturer, :model, :hw_version, :sw_version, :host, :port,
                  capabilities_attributes: %i[id enabled retrievable capability_type state state_instance state_value path pin status _destroy])
  end
end
