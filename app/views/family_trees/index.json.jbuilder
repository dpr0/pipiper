# frozen_string_literal: true

json.array! @family_trees, partial: 'family_trees/family_tree', as: :family_tree
