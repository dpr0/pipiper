class ActionService
  def initialize(user_id, list)
    @user_devices = Device.enabled(user_id).all
    @list = list
  end

  def call
    @list.map do |d|
      ud = @user_devices.find(d[:id])
      {
        id: d[:id].to_s,
        name: ud.name,
        description: ud.description,
        room: ud.room,
        type: ud.device_type,
        custom_data: {},
        device_info: ud.device_info,
        capabilities: capabilities(d[:capabilities], ud)
      }
    end
  end

  private

  def capabilities(capabilities, ud) # ud - user_device
    capabilities.map do |cap|
      dc = ud.capabilities.find_by(capability_type: cap[:type]) # device_capability
      dc.update(status: cap[:state][:value])
      state = set_state(cap[:state])
      code = if ud.protocol.code == 'mqtt'
        name = ud.host
        if name.include?('drivent')
          mq("#{name}/setTargetPosition", state)
        elsif name.include?('shelly')
          if cap[:state][:instance] == 'on'
            mq("shellies/#{name}/relay/#{ud.port}/command", cap[:state][:value] ? 'on' : 'off')
          end
        elsif name.include?('defafon')
          mq('defafon/v1/in', cap[:state][:instance] == 'on' ? 'O' : 'N')
        end
      else
        path = cap[:state][:value] == 100 ? 'set_' : 'reset_'
        url = "http://#{ud.host}:#{ud.port}/#{path}#{dc.path}/#{dc.pin}"
        puts url
        resp = RestClient.get(url)
        puts resp.code
        # resp = RestClient.get("http://#{ud.host}:#{ud.port}/#{dc.path}/#{dc.pin}")
        # resp = RestClient.post("http://#{ud.host}:#{ud.port}/#{dc.path}", { pin: dc.pin, status: cap[:state][:value] }.to_json)
        resp.code
      end
      # response = JSON.parse(resp.body)
      {
        type: cap[:type],
        # retrievable: cap[:v],
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
  end

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
end
