# frozen_string_literal: true

class AddRootPersonIdToFamilyTreeUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :family_trees_users, :root_person_id, :integer
  end
end
