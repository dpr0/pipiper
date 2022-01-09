# frozen_string_literal: true

class CreatePhotos < ActiveRecord::Migration[6.1]
  def change
    create_table :photos do |t|
      t.integer :person_id
      t.integer :attachment_id
      t.date :date
      t.string :info
      t.timestamps null: false
    end
  end
end
