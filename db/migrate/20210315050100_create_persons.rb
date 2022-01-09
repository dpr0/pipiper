# frozen_string_literal: true

class CreatePersons < ActiveRecord::Migration[6.1]
  def change
    create_table :persons do |t|
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :maiden_name
      t.integer :sex_id
      t.integer :father_id
      t.integer :mother_id
      t.integer :family_tree_id
      t.date :birthdate
      t.date :deathdate
      t.string :address
      t.string :contact
      t.string :document
      t.string :info
      t.timestamps null: false
    end
  end
end
