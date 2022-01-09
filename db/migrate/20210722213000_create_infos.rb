# frozen_string_literal: true

class CreateInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :infos do |t|
      t.integer :person_id
      t.integer :info_type_id
      t.string :value
      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
