# frozen_string_literal: true

class CreateSex < ActiveRecord::Migration[6.1]
  def change
    create_table :sex do |t|
      t.string :code
      t.string :name
    end
  end
end
