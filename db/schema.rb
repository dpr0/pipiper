# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_220_122_190_000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'active_storage_attachments', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'record_type', null: false
    t.bigint 'record_id', null: false
    t.bigint 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index ['record_type', 'record_id', 'name', 'blob_id'], name: 'index_active_storage_attachments_uniqueness', unique: true
  end

  create_table 'active_storage_blobs', force: :cascade do |t|
    t.string 'key', null: false
    t.string 'filename', null: false
    t.string 'content_type'
    t.text 'metadata'
    t.string 'service_name', null: false
    t.bigint 'byte_size', null: false
    t.string 'checksum', null: false
    t.datetime 'created_at', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_variant_records', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.string 'variation_digest', null: false
    t.index ['blob_id', 'variation_digest'], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end

  create_table 'archives', force: :cascade do |t|
    t.integer 'person_id'
    t.date 'date'
    t.string 'info'
    t.string 'location'
    t.string 'filename'
    t.string 'content_type'
    t.string 'url'
    t.datetime 'deleted_at'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'authorizations', force: :cascade do |t|
    t.bigint 'user_id'
    t.string 'provider'
    t.string 'uid'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['provider', 'uid'], name: 'index_authorizations_on_provider_and_uid'
    t.index ['user_id'], name: 'index_authorizations_on_user_id'
  end

  create_table 'fact_types', force: :cascade do |t|
    t.string 'code'
    t.string 'name'
    t.string 'for_man'
    t.string 'for_woman'
  end

  create_table 'facts', force: :cascade do |t|
    t.integer 'person_id'
    t.date 'date'
    t.string 'info'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.datetime 'deleted_at'
    t.string 'location'
    t.integer 'fact_type_id'
  end

  create_table 'family_trees', force: :cascade do |t|
    t.integer 'user_id'
    t.string 'name'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'family_trees_users', force: :cascade do |t|
    t.integer 'family_tree_id'
    t.integer 'user_id'
    t.integer 'role_id'
    t.datetime 'created_at'
    t.integer 'root_person_id'
    t.index ['family_tree_id', 'user_id'], name: 'index_family_trees_users_on_family_tree_id_and_user_id'
    t.index ['user_id', 'family_tree_id'], name: 'index_family_trees_users_on_user_id_and_family_tree_id'
  end

  create_table 'info_types', force: :cascade do |t|
    t.string 'code'
    t.string 'name'
  end

  create_table 'infos', force: :cascade do |t|
    t.integer 'person_id'
    t.integer 'info_type_id'
    t.string 'value'
    t.datetime 'deleted_at'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'persons', force: :cascade do |t|
    t.string 'last_name'
    t.string 'first_name'
    t.string 'middle_name'
    t.string 'maiden_name'
    t.integer 'sex_id'
    t.integer 'father_id'
    t.integer 'mother_id'
    t.integer 'family_tree_id'
    t.date 'birthdate'
    t.date 'deathdate'
    t.string 'address'
    t.string 'contact'
    t.string 'document'
    t.string 'info'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.string 'link_vk'
    t.string 'link_fb'
    t.string 'link_ig'
    t.string 'link_ok'
    t.string 'link_tg'
    t.string 'link_tw'
    t.string 'link_tt'
    t.string 'link_ch'
    t.boolean 'confirmed_last_name', default: true
    t.boolean 'confirmed_first_name', default: true
    t.boolean 'confirmed_middle_name', default: true
    t.boolean 'confirmed_maiden_name', default: true
    t.boolean 'confirmed_birthdate', default: true
    t.boolean 'confirmed_deathdate', default: true
    t.datetime 'deleted_at'
    t.string 'avatar_url'
  end

  create_table 'photos', force: :cascade do |t|
    t.integer 'person_id'
    t.date 'date'
    t.string 'info'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.string 'url'
    t.string 'location'
    t.datetime 'deleted_at'
  end

  create_table 'relation_types', force: :cascade do |t|
    t.string 'code'
    t.string 'name'
  end

  create_table 'relations', force: :cascade do |t|
    t.integer 'person_id'
    t.integer 'persona_id'
    t.integer 'relation_type_id'
  end

  create_table 'relationship_types', force: :cascade do |t|
    t.string 'code'
    t.string 'name'
  end

  create_table 'roles', force: :cascade do |t|
    t.string 'code'
    t.string 'name'
  end

  create_table 'sex', force: :cascade do |t|
    t.string 'code'
    t.string 'name'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'uid'
    t.string 'name'
    t.string 'email'
    t.string 'phone'
    t.string 'provider'
    t.string 'token'
    t.integer 'person_id'
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer 'sign_in_count', default: 0, null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.inet 'current_sign_in_ip'
    t.inet 'last_sign_in_ip'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.string 'first_name'
    t.string 'last_name'
    t.string 'middle_name'
    t.datetime 'birthdate'
    t.integer 'sex_id'
    t.string 'smscode'
    t.boolean 'is_active'
    t.string 'callcheck'
  end

  create_table 'versions', force: :cascade do |t|
    t.string 'model'
    t.integer 'model_id'
    t.json 'model_changes'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.integer 'person_id'
    t.integer 'family_tree_id'
    t.string 'event_type'
    t.datetime 'deleted_at'
    t.integer 'modifier_id'
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'authorizations', 'users'
end
