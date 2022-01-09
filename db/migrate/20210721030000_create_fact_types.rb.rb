# frozen_string_literal: true

class CreateFactTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :fact_types do |t|
      t.string :code
      t.string :name
      t.string :for_man
      t.string :for_woman
    end
  end
end
