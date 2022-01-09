# frozen_string_literal: true

class FamilyTreeUser < ApplicationRecord
  self.table_name = :family_trees_users

  belongs_to :user
  belongs_to :family_tree
  belongs_to :role

  def owner?
    role_id == Role[:owner].id
  end

  def write?
    [Role[:owner].id, Role[:editor].id].include? role_id
  end

  def read?
    [Role[:owner].id, Role[:editor].id, Role[:guest].id].include? role_id
  end
end
