# frozen_string_literal: true

class CreateProperties < ActiveRecord::Migration[6.0]
  def change
    create_table :properties do |t|
      t.integer :device_id
      t.boolean :enabled
      t.boolean :retrievable
      t.boolean :reportable
      t.string  :property_type
      t.string  :parameters_instance
      t.string  :parameters_value
      t.string  :parameters_unit
      t.string  :parameters_events

      t.timestamps
    end
  end
end
