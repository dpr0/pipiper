# frozen_string_literal: true

class UsersController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :doorkeeper_authorize! # -> { doorkeeper_authorize! :read, :write }

  def index
    head(:ok)
  end

  def show; end

  def unlink
    render_status({})
  end

  def devices
    render_status(user_id: current_user.id.to_s, devices: Device.user_devices(current_user.id))
  end

  def query
    render_status(devices: Device.user_query(current_user.id))
  end

  def action
    user_devices = Device.enabled(current_user.id).all
    devices_response = (params.dig(:payload, :devices) || []).map do |d|
      ud = user_devices.find(d[:id]) # user_device
      {
        id: d[:id].to_s,
        name: ud.name,
        description: ud.description,
        room: ud.room,
        type: ud.device_type,
        custom_data: {},
        device_info: {manufacturer: ud.manufacturer, model: ud.model, hw_version: ud.hw_version, sw_version: ud.sw_version},
        capabilities: d[:capabilities].map do |cap|
          dc = ud.capabilities.find_by(capability_type: cap[:type]) # device_capability
          dc.update(status: cap[:state][:value])
          state = set_state(cap[:state])
          code = if ud.host.split('/').first == 'mqtt'
            name = ud.host.split('/').last
            mq("#{name}/setTargetPosition", state) if name.include?('drivent')
            mq('defafon/v1/in', cap[:state][:instance] == 'on' ? 'O' : 'N') if name.include?('defafon')
          else
            resp = RestClient.post("http://#{ud.host}:#{ud.port}/#{dc.path}", { pin: dc.pin, status: cap[:state][:value] }.to_json)
            resp.code
          end
          # response = JSON.parse(resp.body)
          {
              type: cap[:type],
              # retrievable: cap[:retrievable],
              # reportable: cap[:reportable],
              parameters: {
                  instance: dc.state_instance
              },
              state: {
                  instance: dc.state_instance,
                  value: state,
                  action_result: { status: code == 200 ? 'DONE' : 'ERROR' }
              }
          }
        end
      }
    end
    render_status(user_id: current_user.id.to_s, devices: devices_response)
  end

  private

  def mq(path, state)
    if mqtt_client
      mqtt_client.publish(path, state, true)
      mqtt_client.disconnect
      200
    else
      500
    end
  end

  def set_state(state)
    case state[:instance]
    when 'on'   then state[:value] ? 100 : 0
    when 'open' then state[:value].to_i
    else             state[:value] ? 100 : 0
    end
  end

  def mqtt_client
    @mqtt_client ||= MQTT::Client.connect(ENV['MQTT_HOST'], port: ENV['MQTT_PORT'], username: ENV['MQTT_USER'], password: ENV['MQTT_PASS'])
  rescue
    nil
  end

  def current_user
    @user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def render_status(payload = {})
    json = { request_id: request.headers['X-Request-Id'], payload: payload }
    Rails.logger.info JSON.pretty_generate(json)
    render status: :ok, json: json
  end
end
