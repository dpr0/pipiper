# frozen_string_literal: true

class Property < ApplicationRecord
  belongs_to :device, inverse_of: :properties

  TYPES = [
    ['Показания датчиков событий', 'devices.properties.event'],
    ['Показания датчиков в числовом формате', 'devices.properties.float']
  ].freeze

end
