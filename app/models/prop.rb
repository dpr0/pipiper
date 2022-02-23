# frozen_string_literal: true

class Prop < ApplicationRecord
  belongs_to :device, inverse_of: :props

  TYPES = ['devices.properties.event', 'devices.properties.float'].freeze

  INSTANCE_EVENT = [
    'battery_level',
    'button',
    'gas',
    'motion',
    'open',
    'smoke',
    'vibration',
    'water_level',
    'water_leak',
  ].freeze

  INSTANCE_FLOAT = [
    'battery_level',
    'co2_level',
    'humidity',
    'illumination',
    'pm1_density',
    'pm2.5_density',
    'pm10_density',
    'pressure',
    'temperature',
    'tvoc',
    'water_level'
  ].freeze

end
