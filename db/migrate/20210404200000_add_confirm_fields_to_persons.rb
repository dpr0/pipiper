# frozen_string_literal: true

class AddConfirmFieldsToPersons < ActiveRecord::Migration[6.1]
  def change
    add_column :persons, :confirmed_last_name,   :boolean, default: true
    add_column :persons, :confirmed_first_name,  :boolean, default: true
    add_column :persons, :confirmed_middle_name, :boolean, default: true
    add_column :persons, :confirmed_maiden_name, :boolean, default: true
    add_column :persons, :confirmed_birthdate,   :boolean, default: true
  end
end
