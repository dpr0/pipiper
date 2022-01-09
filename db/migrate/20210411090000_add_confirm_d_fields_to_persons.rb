# frozen_string_literal: true

class AddConfirmDFieldsToPersons < ActiveRecord::Migration[6.1]
  def change
    add_column :persons, :confirmed_deathdate, :boolean, default: true
  end
end
