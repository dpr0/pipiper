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

end
