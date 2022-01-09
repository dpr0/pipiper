# frozen_string_literal: true

class CreateFacts < ActiveRecord::Migration[6.1]
  def change
    create_table :facts do |t|
      t.integer :person_id
      t.date :date
      t.string :info
      t.timestamps null: false
    end
  end
end
