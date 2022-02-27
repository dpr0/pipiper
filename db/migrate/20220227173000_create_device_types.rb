# frozen_string_literal: true

class CreateDeviceTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :device_types do |t|
      t.string  :code
      t.string  :name
    end
  end
end
