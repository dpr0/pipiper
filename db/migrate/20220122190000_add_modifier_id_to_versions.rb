# frozen_string_literal: true

class AddModifierIdToVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :versions, :modifier_id, :integer
  end
end
