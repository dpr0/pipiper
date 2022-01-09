# frozen_string_literal: true

class FamilyTree < ApplicationRecord
  has_many :persons
  has_many :family_tree_users, dependent: :destroy
  has_many :users, through: :family_tree_users, inverse_of: :family_trees, dependent: :destroy
end
