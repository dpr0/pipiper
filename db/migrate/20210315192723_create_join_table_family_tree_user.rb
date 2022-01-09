class CreateJoinTableFamilyTreeUser < ActiveRecord::Migration[6.1]
  def change
    create_table :family_trees_users do |t|
      t.integer :family_tree_id
      t.integer :user_id
      t.integer :role_id
      t.timestamp :created_at
    end

    add_index :family_trees_users, [:family_tree_id, :user_id]
    add_index :family_trees_users, [:user_id, :family_tree_id]
  end
end
