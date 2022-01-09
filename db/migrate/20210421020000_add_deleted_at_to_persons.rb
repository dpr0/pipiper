# frozen_string_literal: true

class AddDeletedAtToPersons < ActiveRecord::Migration[6.1]
  def change
    add_column :persons, :deleted_at, :datetime
    add_column :facts,   :deleted_at, :datetime
  end
end
