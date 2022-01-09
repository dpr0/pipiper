# frozen_string_literal: true

class CreateInfoTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :info_types do |t|
      t.string :code
      t.string :name
    end
  end
end
