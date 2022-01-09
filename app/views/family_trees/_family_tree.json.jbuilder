# frozen_string_literal: true

json.extract! family_tree, :id, :user_id, :name, :created_at, :updated_at
json.url family_tree_url(family_tree, format: :json)
