mqtt = Protocol.create(code: 'mqtt', name: 'MQTT')
http = Protocol.create(code: 'http', name: 'HTTP')

DeviceType.create(name: 'Лампочка, светильник, люстра.',                                 code: 'devices.types.light')
DeviceType.create(name: 'Розетка.',                                                      code: 'devices.types.socket')
DeviceType.create(name: 'Выключатель, реле.',                                            code: 'devices.types.switch')
DeviceType.create(name: 'Водонагреватель, теплый пол, обогреватель, электровентилятор.', code: 'devices.types.thermostat')
DeviceType.create(name: 'Кондиционер.',                                                  code: 'devices.types.thermostat.ac')
DeviceType.create(name: 'Аудио, видео, мультимедиа техника.',                            code: 'devices.types.media_device')
DeviceType.create(name: 'Телевизор, ИК-пульт от телевизора',                             code: 'devices.types.media_device.tv')
DeviceType.create(name: 'ИК-пульт от тв-приставки, тв-приставка.',                       code: 'devices.types.media_device.tv_box')
DeviceType.create(name: 'ИК-пульт от ресивера, ресивер.',                                code: 'devices.types.media_device.receiver')
DeviceType.create(name: 'Различная умная кухонная техника.',                             code: 'devices.types.cooking')
DeviceType.create(name: 'Кофеварка, кофемашина.',                                        code: 'devices.types.cooking.coffee_maker')
DeviceType.create(name: 'Чайник.',                                                       code: 'devices.types.cooking.kettle')
DeviceType.create(name: 'Мультиварка.',                                                  code: 'devices.types.cooking.multicooker')
DeviceType.create(name: 'Дверь, ворота, окно, ставни.',                                  code: 'devices.types.openable')
DeviceType.create(name: 'Шторы, жалюзи.',                                                code: 'devices.types.openable.curtain')
DeviceType.create(name: 'Увлажнитель воздуха.',                                          code: 'devices.types.humidifier')
DeviceType.create(name: 'Очиститель воздуха.',                                           code: 'devices.types.purifier')
DeviceType.create(name: 'Робот-пылесос.',                                                code: 'devices.types.vacuum_cleaner')
DeviceType.create(name: 'Стиральная машина.',                                            code: 'devices.types.washing_machine')
DeviceType.create(name: 'Посудомоечная машина.',                                         code: 'devices.types.dishwasher')
DeviceType.create(name: 'Утюг, парогенератор.',                                          code: 'devices.types.iron')
DeviceType.create(name: 'Датчик температуры, влажности, открытия двери, движения.',      code: 'devices.types.sensor')
DeviceType.create(name: 'Остальные устройства.',                                         code: 'devices.types.other')

device1 = Device.create(
  user_id: 1,
  enabled: true,
  name: 'Окно',
  description: 'проветривание',
  room: 'Кухня',
  device_type: 'devices.types.openable',
  manufacturer: 'Drivent',
  host: 'drivent_dpro',
  port: nil,
  protocol_id: mqtt.id)

device2 = Device.create(
  user_id: 1,
  enabled: true,
  name: 'Домофон',
  description: 'Входная дверь',
  room: 'Прихожая',
  device_type: 'devices.types.openable',
  manufacturer: 'Defafon',
  host: 'defafon_dpro',
  port: nil,
  protocol_id: mqtt.id)

device3 = Device.create(
  user_id: 1,
  enabled: true,
  name: 'Свет',
  description: 'освещение',
  room: 'Кухня',
  device_type: 'devices.types.light',
  manufacturer: 'Shelly',
  host: 'shelly25_dpro',
  port: 0,
  protocol_id: mqtt.id)

capability1 = Capability.create(
  device_id: device1.id,
  status: true,
  enabled: true,
  retrievable: true,
  capability_type: 'devices.capabilities.on_off',
  state_instance: 'on',
  state_value: 1)

capability2 = Capability.create(
  device_id: device1.id,
  status: true,
  enabled: true,
  retrievable: true,
  capability_type: 'devices.capabilities.range',
  state_instance: 'on',
  state_value: 1)

capability3 = Capability.create(
  device_id: device2.id,
  status: false,
  enabled: true,
  retrievable: true,
  capability_type: 'devices.capabilities.on_off',
  state_instance: 'on',
  state_value: 1)

capability3 = Capability.create(
  device_id: device3.id,
  status: false,
  enabled: true,
  retrievable: true,
  capability_type: 'devices.capabilities.on_off',
  state_instance: 'on',
  state_value: 1)
