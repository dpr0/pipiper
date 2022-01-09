# frozen_string_literal: true

class AddLocationToFacts < ActiveRecord::Migration[6.1]
  def change
    add_column :facts, :location, :string
  end
end
