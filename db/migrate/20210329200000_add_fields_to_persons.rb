# frozen_string_literal: true

class AddFieldsToPersons < ActiveRecord::Migration[6.1]
  def change
    add_column :persons, :link_vk, :string # vkontakte
    add_column :persons, :link_fb, :string # facebook
    add_column :persons, :link_ig, :string # instagram
    add_column :persons, :link_ok, :string # odnoklassniki
    add_column :persons, :link_tg, :string # telegram
    add_column :persons, :link_tw, :string # twitter
    add_column :persons, :link_tt, :string # tik-tok
    add_column :persons, :link_ch, :string # clubhouse
  end
end
