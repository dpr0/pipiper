# frozen_string_literal: true

class AddSmscodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :smscode, :string
  end
end
