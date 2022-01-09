# frozen_string_literal: true

class AddRootToTree < ActiveRecord::Migration[6.1]
  def change
    add_column :family_trees, :root_person_id, :integer
  end
end
