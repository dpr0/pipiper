# frozen_string_literal: true

class AddAvatarUrlToPersons < ActiveRecord::Migration[6.1]
  def change
    add_column :persons, :avatar_url, :string
  end
end
