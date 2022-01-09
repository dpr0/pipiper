# frozen_string_literal: true

class RenameColumnVersions < ActiveRecord::Migration[6.1]
  def change
    rename_column :versions, :user_id, :person_id
  end
end
