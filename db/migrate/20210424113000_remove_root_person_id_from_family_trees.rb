# frozen_string_literal: true

class RemoveRootPersonIdFromFamilyTrees < ActiveRecord::Migration[6.1]
  def change
    remove_column :family_trees, :root_person_id
  end
end
