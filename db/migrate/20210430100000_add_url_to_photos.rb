# frozen_string_literal: true

class AddUrlToPhotos < ActiveRecord::Migration[6.1]
  def change
    add_column :photos, :url, :string
    add_column :photos, :location, :string
    add_column :photos, :deleted_at, :datetime
    remove_column :photos, :attachment_id
  end
end
