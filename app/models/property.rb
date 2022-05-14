# frozen_string_literal: true

class Property < ApplicationRecord
  belongs_to :device, inverse_of: :properties

  TYPES = [
    ['Показания датчиков событий', 'devices.properties.event'],
    ['Показания датчиков в числовом формате', 'devices.properties.float']
  ].freeze

  def to_property
    property = { type: property_type, retrievable: retrievable, reportable: reportable,
                 state: { instance: parameters_instance, value: parameters_value } }
    property[:parameters] = case property_type
                            when 'devices.properties.float'
                              { instance: parameters_instance, unit: parameters_unit }
                            when 'devices.properties.event'
                              {
                                instance: parameters_instance,
                                events: parameters_events&.split(",")&.map { |e| { value: e } }
                              }
                            else
                              {}
                            end
    property
  end
end
