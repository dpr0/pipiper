# frozen_string_literal: true

class AddDeletedAtToVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :deleted_at, :datetime
  end
end
