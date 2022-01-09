# frozen_string_literal: true

class CreateFamilyTrees < ActiveRecord::Migration[6.1]
  def change
    create_table :family_trees do |t|
      t.integer :user_id
      t.string :name
      t.timestamps
    end
  end
end
