# frozen_string_literal: true

class AddInfoTypeIdToFacts < ActiveRecord::Migration[6.1]
  def change
    add_column :facts, :info_type_id, :integer
  end
end
