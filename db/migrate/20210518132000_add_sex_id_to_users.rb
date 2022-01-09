# frozen_string_literal: true

class AddSexIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :sex_id, :integer
  end
end
