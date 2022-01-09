# frozen_string_literal: true

class AddFactTypeIdToFacts < ActiveRecord::Migration[6.1]
  def change
    remove_column :facts, :info_type_id
    add_column    :facts, :fact_type_id, :integer
  end
end
