# frozen_string_literal: true

class Capability < ApplicationRecord
  belongs_to :device, inverse_of: :capabilities

  TYPES = [
    ['Вкл/выкл.',                               'devices.capabilities.on_off'        ],
    ['Управление цветом.',                      'devices.capabilities.color_setting' ],
    ['Переключение режимов работы устройства.', 'devices.capabilities.mode'          ],
    ['Яркость, громкость, температура.',        'devices.capabilities.range'         ],
    ['Вкл/выкл доп. функций.',                  'devices.capabilities.toggle'        ]
  ].freeze

  def to_capability
    capability = { type: capability_type, retrievable: retrievable }
    if capability_type == 'devices.capabilities.range'
      capability[:parameters] = {
        instance: 'open',
        unit: 'unit.percent',
        random_access: true,
        range: {
          min: 0,
          max: 100,
          precision: 1
        }
      }
    end
    capability
  end
end
