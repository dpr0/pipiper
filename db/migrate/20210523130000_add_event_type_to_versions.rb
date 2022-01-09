# frozen_string_literal: true

class AddEventTypeToVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :event_type, :string
  end
end
