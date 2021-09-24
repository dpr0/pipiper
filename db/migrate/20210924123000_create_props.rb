# frozen_string_literal: true

class CreateProps < ActiveRecord::Migration[6.0]
  def change
    create_table :props do |t|
      t.integer :device_id
      t.boolean :enabled
      t.boolean :retrievable
      t.boolean :reportable
      t.string  :prop_type
      t.string  :parameters_instance
      t.string  :parameters_unit
      t.string  :state_instance
      t.integer :state_value

      t.timestamps
    end
  end
end
