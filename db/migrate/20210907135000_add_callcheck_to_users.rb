# frozen_string_literal: true

class AddCallcheckToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_active, :boolean
    add_column :users, :callcheck, :string
  end
end
