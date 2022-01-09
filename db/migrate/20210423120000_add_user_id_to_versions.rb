# frozen_string_literal: true

class AddUserIdToVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :user_id, :integer
    add_column :versions, :family_tree_id, :integer
  end
end
