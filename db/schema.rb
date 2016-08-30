# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160829133020) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attr_values", force: :cascade do |t|
    t.string  "name",    limit: 255
    t.integer "attr_id",             null: false
  end

  create_table "attr_values_labs", id: false, force: :cascade do |t|
    t.integer "attr_value_id", null: false
    t.integer "lab_id",        null: false
  end

  create_table "attr_values_measurements", id: false, force: :cascade do |t|
    t.integer "measurement_id", null: false
    t.integer "attr_value_id",  null: false
  end

  create_table "attr_values_measurements_old", id: false, force: :cascade do |t|
    t.integer "measurement_id",    null: false
    t.integer "attr_value_id",     null: false
    t.integer "new_attr_value_id"
  end

  create_table "attr_values_old", force: :cascade do |t|
    t.integer "attr_id",                       null: false
    t.string  "value",             limit: 255
    t.boolean "deprecated"
    t.integer "new_attr_id"
    t.integer "new_attr_value_id"
  end

  create_table "attr_values_samples", id: false, force: :cascade do |t|
    t.integer "sample_id",     null: false
    t.integer "attr_value_id", null: false
  end

  create_table "attr_values_samples_old", id: false, force: :cascade do |t|
    t.integer "sample_id",         null: false
    t.integer "attr_value_id",     null: false
    t.integer "new_attr_value_id"
  end

  create_table "attrs", force: :cascade do |t|
    t.string  "name",       limit: 255
    t.integer "widget_id",              null: false
    t.string  "owner",      limit: 255
    t.boolean "deprecated"
    t.boolean "new"
  end

  create_table "attrs_exp_types", id: false, force: :cascade do |t|
    t.integer "attr_id",     null: false
    t.integer "exp_type_id", null: false
  end

  create_table "attrs_labs", id: false, force: :cascade do |t|
    t.integer "attr_id",             null: false
    t.integer "lab_id",              null: false
    t.string  "owner",   limit: 255
  end

  create_table "attrs_measurements", id: false, force: :cascade do |t|
    t.integer "measurement_id", null: false
    t.integer "attr_id",        null: false
  end

  create_table "attrs_old", force: :cascade do |t|
    t.integer "lab_id",                  null: false
    t.string  "key",         limit: 255
    t.boolean "fixed_value"
    t.boolean "searchable"
    t.boolean "deprecated"
    t.string  "widget",      limit: 255
    t.string  "owner",       limit: 255
    t.integer "new_id"
  end

  create_table "attrs_samples", id: false, force: :cascade do |t|
    t.integer "sample_id", null: false
    t.integer "attr_id",   null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "exp_types", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "exps", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.integer  "user_id",     null: false
    t.integer  "exp_type_id", null: false
    t.integer  "project_id"
    t.text     "name"
  end

  create_table "exps_projects", id: false, force: :cascade do |t|
    t.integer "exp_id",     null: false
    t.integer "project_id", null: false
  end

  create_table "fus", force: :cascade do |t|
    t.string "filename",     limit: 255
    t.string "sha1",         limit: 255
    t.string "path",         limit: 255
    t.string "url_path",     limit: 255
    t.string "extension",    limit: 255
    t.string "vitalit_path", limit: 255
  end

  create_table "fus_measurements", id: false, force: :cascade do |t|
    t.integer "measurement_id", null: false
    t.integer "fu_id",          null: false
  end

  create_table "group_permissions", id: false, force: :cascade do |t|
    t.integer "group_id",      null: false
    t.integer "permission_id", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "user_id",  null: false
    t.integer "group_id", null: false
  end

  create_table "labs", force: :cascade do |t|
    t.string "name",           limit: 255
    t.string "path_raw",       limit: 255
    t.string "path_processed", limit: 255
    t.string "path_tmp",       limit: 255
  end

  create_table "labs_projects", id: false, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "lab_id",     null: false
  end

  create_table "labs_users", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "lab_id",  null: false
  end

  create_table "measurement_rels", id: false, force: :cascade do |t|
    t.integer "parent_id", null: false
    t.integer "child_id",  null: false
  end

  create_table "measurements", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.string   "name",        limit: 255
    t.text     "description"
    t.boolean  "public"
    t.boolean  "raw"
    t.datetime "created_at"
    t.integer  "fu_id"
  end

  create_table "measurements_samples", id: false, force: :cascade do |t|
    t.integer "sample_id",      null: false
    t.integer "measurement_id", null: false
  end

  create_table "migrate_version", primary_key: "repository_id", force: :cascade do |t|
    t.text    "repository_path"
    t.integer "version"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name", limit: 63, null: false
  end

  add_index "permissions", ["name"], name: "permissions_name_key", unique: true, using: :btree

  create_table "projects", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.text     "description"
    t.string   "key",         limit: 6
  end

  create_table "samples", force: :cascade do |t|
    t.integer  "project_id",              null: false
    t.string   "name",        limit: 255
    t.string   "exp_type",    limit: 255
    t.datetime "created_at"
    t.text     "protocole"
    t.text     "description"
    t.integer  "exp_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "firstname",  limit: 255
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.string   "key",        limit: 255
  end

  add_index "users", ["email"], name: "users_email_key", unique: true, using: :btree
  add_index "users", ["key"], name: "users_key_key", unique: true, using: :btree

  create_table "widgets", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.boolean "fixed_value"
  end

  add_foreign_key "attr_values", "attrs", name: "attr_values_attr_id_fkey", on_delete: :cascade
  add_foreign_key "attr_values_labs", "attr_values", name: "attr_values_labs_attr_value_id_fkey", on_delete: :cascade
  add_foreign_key "attr_values_labs", "labs", name: "attr_values_labs_lab_id_fkey", on_delete: :cascade
  add_foreign_key "attr_values_measurements", "attr_values", name: "attr_values_measurements_attr_value_id_fkey", on_delete: :cascade
  add_foreign_key "attr_values_measurements", "measurements", name: "attr_values_measurements_measurement_id_fkey", on_delete: :cascade
  add_foreign_key "attr_values_measurements_old", "attr_values_old", column: "attr_value_id", name: "Cross_meas_attributvalues_attributvalues_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attr_values_measurements_old", "measurements", name: "Cross_meas_attributvalues_measurement_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attr_values_old", "attr_values", column: "new_attr_value_id", name: "attr_values_old_new_attr_value_id_fkey"
  add_foreign_key "attr_values_old", "attrs", column: "new_attr_id", name: "attr_values_old_new_attr_id_fkey"
  add_foreign_key "attr_values_old", "attrs_old", column: "attr_id", name: "Attributs_values_attribut_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attr_values_samples", "attr_values", name: "attr_values_samples_attr_value_id_fkey", on_delete: :cascade
  add_foreign_key "attr_values_samples", "samples", name: "attr_values_samples_sample_id_fkey", on_delete: :cascade
  add_foreign_key "attr_values_samples_old", "attr_values_old", column: "attr_value_id", name: "Cross_sample_attributvalues_attributvalues_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attr_values_samples_old", "samples", name: "Cross_sample_attributvalues_sample_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attrs", "widgets", name: "attrs_widget_id_fkey"
  add_foreign_key "attrs_exp_types", "attrs", name: "attrs_exp_types_attr_id_fkey"
  add_foreign_key "attrs_exp_types", "exp_types", name: "attrs_exp_types_exp_type_id_fkey"
  add_foreign_key "attrs_labs", "attrs", name: "attrs_labs_attr_id_fkey", on_delete: :cascade
  add_foreign_key "attrs_labs", "labs", name: "attrs_labs_lab_id_fkey", on_delete: :cascade
  add_foreign_key "attrs_measurements", "attrs_old", column: "attr_id", name: "Cross_measurement_attribut_attribut_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attrs_measurements", "measurements", name: "Cross_measurement_attribut_measurement_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attrs_old", "labs", name: "Attributs_lab_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attrs_samples", "attrs_old", column: "attr_id", name: "Cross_sample_attribut_attribut_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attrs_samples", "samples", name: "Cross_sample_attribut_sample_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "exps", "exp_types", name: "exps_exp_type_id_fkey"
  add_foreign_key "exps", "projects", name: "exps_project_id_fkey"
  add_foreign_key "exps", "users", name: "exps_user_id_fkey"
  add_foreign_key "exps_projects", "exps", name: "exps_projects_exp_id_fkey", on_delete: :cascade
  add_foreign_key "exps_projects", "projects", name: "exps_projects_project_id_fkey", on_delete: :cascade
  add_foreign_key "fus_measurements", "fus", name: "Cross_meas_fu_fu_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "fus_measurements", "measurements", name: "Cross_meas_fu_measurement_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "group_permissions", "groups", name: "GroupPermissions_group_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "group_permissions", "permissions", name: "GroupPermissions_permission_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "groups_users", "groups", name: "UserGroup_group_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "groups_users", "users", name: "UserGroup_user_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "labs_projects", "labs", name: "Cross_projects_lab_lab_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "labs_projects", "projects", name: "Cross_projects_lab_project_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "labs_users", "labs", name: "Cross_user_lab_lab_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "labs_users", "users", name: "Cross_user_lab_user_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "measurement_rels", "measurements", column: "child_id", name: "Cross_measurements_child_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "measurement_rels", "measurements", column: "parent_id", name: "Cross_measurements_parent_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "measurements", "fus", name: "measurements_fu_id_fkey"
  add_foreign_key "measurements", "users", name: "Measurements_user_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "measurements_samples", "measurements", name: "Cross_sample_measurement_measurement_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "measurements_samples", "samples", name: "Cross_sample_measurement_sample_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "projects", "users", name: "Projects_user_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "samples", "exps", name: "samples_exp_id_fkey"
  add_foreign_key "samples", "projects", name: "Samples_project_id_fkey", on_update: :cascade, on_delete: :cascade
end
