# frozen_string_literal: true

class CreateRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :relations do |t|
      t.integer :person_id
      t.integer :persona_id
      t.integer :relation_type_id
    end
  end
end
