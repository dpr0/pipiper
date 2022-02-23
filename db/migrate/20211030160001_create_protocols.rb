# frozen_string_literal: true

class CreateProtocols < ActiveRecord::Migration[6.0]
  def change
    create_table :protocols do |t|
      t.string  :code
      t.string  :name
      t.timestamps
    end
  end
end
