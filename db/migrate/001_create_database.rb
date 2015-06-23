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

class CreateDatabase < ActiveRecord::Migration
	def self.up
		ActiveRecord::Schema.define(version: 1) do

		  create_table "admin", id: false, force: :cascade do |t|
			t.string "username", limit: 20,  null: false
			t.string "password", limit: 100, null: false
		  end

		  create_table "blog", force: :cascade do |t|
			t.string  "title",    limit: 100,   null: false
			t.text    "post",     limit: 65535, null: false
			t.date    "created",                null: false
			t.date    "modified",               null: false
			t.boolean "active",   limit: 1,     null: false
		  end

		  create_table "comment", force: :cascade do |t|
			t.string  "name",       limit: 100,   null: false
			t.string  "email",      limit: 100,   null: false
			t.text    "comment",    limit: 65535, null: false
			t.date    "created",                  null: false
			t.integer "markedread", limit: 4,     null: false
			t.integer "blogid",     limit: 4,     null: false
			t.boolean "active",     limit: 1,     null: false
		  end

		  create_table "ingredients", force: :cascade do |t|
			t.integer "recipe_id",  limit: 4,   null: false
			t.integer "sort_order", limit: 4,   null: false
			t.string  "amount",     limit: 20
			t.string  "unit",       limit: 20
			t.string  "ingredient", limit: 100, null: false
			t.date    "added",                  null: false
			t.date    "modified",               null: false
		  end

		  add_index "ingredients", ["recipe_id"], name: "recipe_id_index", using: :btree

		  create_table "recipe_images", force: :cascade do |t|
			t.string   "extension", limit: 10
			t.integer  "recipe_id", limit: 4,  null: false
			t.datetime "added",                null: false
		  end

		  create_table "recipe_x_tags", id: false, force: :cascade do |t|
			t.integer "recipe_id", limit: 4, null: false
			t.integer "tag_id",    limit: 4, null: false
		  end

		  add_index "recipe_x_tags", ["recipe_id", "tag_id"], name: "tag_id_index", using: :btree

		  create_table "recipes", force: :cascade do |t|
			t.string   "title",     limit: 100,                 null: false
			t.time     "prep_time"
			t.time     "cook_time"
			t.integer  "serves",    limit: 4
			t.integer  "user_id",   limit: 4,                   null: false
			t.string   "user",      limit: 100,                 null: false
			t.datetime "added",                                 null: false
			t.datetime "modified",                              null: false
			t.boolean  "published", limit: 1,   default: false
		  end

		  create_table "steps", force: :cascade do |t|
			t.integer "recipe_id",   limit: 4,     null: false
			t.integer "sort_order",  limit: 4,     null: false
			t.text    "description", limit: 65535, null: false
			t.date    "added",                     null: false
			t.date    "modified",                  null: false
		  end

		  add_index "steps", ["recipe_id"], name: "recipe_id_index", using: :btree

		  create_table "tags", force: :cascade do |t|
			t.string "keyword", limit: 100, null: false
		  end

		  add_index "tags", ["id"], name: "recipe_id_index", using: :btree
		  add_index "tags", ["keyword"], name: "keyword_unique_constraint", unique: true, using: :btree

		  create_table "user_emails", force: :cascade do |t|
			t.integer "user_id", limit: 4,   null: false
			t.string  "email",   limit: 100, null: false
		  end

		  add_index "user_emails", ["email"], name: "email", unique: true, using: :btree

		  create_table "users", force: :cascade do |t|
			t.string   "username",  limit: 100, null: false
			t.string   "hash",      limit: 100, null: false
			t.boolean  "suspended", limit: 1,   null: false
			t.datetime "added",                 null: false
			t.datetime "modified",              null: false
		  end

		  add_index "users", ["username"], name: "username", unique: true, using: :btree

		end
	end
end