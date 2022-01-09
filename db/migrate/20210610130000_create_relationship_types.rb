# frozen_string_literal: true

class CreateRelationshipTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :relationship_types do |t|
      t.string :code
      t.string :name
    end
  end
end
