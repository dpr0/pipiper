# frozen_string_literal: true

class CreateArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :archives do |t|
      t.integer :person_id
      t.date :date
      t.string :info
      t.string :location
      t.string :filename
      t.string :content_type
      t.string :url
      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
