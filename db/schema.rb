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

ActiveRecord::Schema.define(version: 2019_10_31_083711) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "character_classes", force: :cascade do |t|
    t.jsonb "name", default: {"en"=>"", "ru"=>""}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_character_classes_on_name", using: :gin
  end

  create_table "character_professions", force: :cascade do |t|
    t.integer "character_id"
    t.integer "profession_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id", "profession_id"], name: "index_character_professions_on_character_id_and_profession_id", unique: true
  end

  create_table "character_recipes", force: :cascade do |t|
    t.integer "recipe_id"
    t.integer "character_profession_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "character_profession_id"], name: "character_recipes_index", unique: true
  end

  create_table "character_roles", force: :cascade do |t|
    t.integer "character_id"
    t.integer "role_id"
    t.boolean "main", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id", "role_id"], name: "index_character_roles_on_character_id_and_role_id"
  end

  create_table "characters", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "level", default: 60, null: false
    t.integer "race_id"
    t.integer "character_class_id"
    t.integer "user_id"
    t.integer "world_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "guild_id"
    t.index ["character_class_id"], name: "index_characters_on_character_class_id"
    t.index ["guild_id"], name: "index_characters_on_guild_id"
    t.index ["name"], name: "index_characters_on_name"
    t.index ["race_id"], name: "index_characters_on_race_id"
    t.index ["user_id"], name: "index_characters_on_user_id"
    t.index ["world_id"], name: "index_characters_on_world_id"
  end

  create_table "combinations", force: :cascade do |t|
    t.integer "character_class_id"
    t.integer "combinateable_id"
    t.string "combinateable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_class_id"], name: "index_combinations_on_character_class_id"
    t.index ["combinateable_id", "combinateable_type"], name: "index_combinations_on_combinateable_id_and_combinateable_type"
  end

  create_table "dungeon_accesses", force: :cascade do |t|
    t.integer "character_id"
    t.integer "dungeon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id", "dungeon_id"], name: "index_dungeon_accesses_on_character_id_and_dungeon_id", unique: true
  end

  create_table "dungeons", force: :cascade do |t|
    t.jsonb "name", default: {"en"=>"", "ru"=>""}, null: false
    t.boolean "raid", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "key_access", default: false, null: false
    t.boolean "quest_access", default: false, null: false
    t.index ["name"], name: "index_dungeons_on_name", using: :gin
  end

  create_table "events", force: :cascade do |t|
    t.integer "owner_id"
    t.string "name"
    t.string "event_type"
    t.datetime "start_time"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "dungeon_id"
    t.integer "eventable_id"
    t.string "eventable_type"
    t.integer "fraction_id"
    t.integer "hours_before_close", default: 0, null: false
    t.text "description", default: "", null: false
    t.index ["dungeon_id"], name: "index_events_on_dungeon_id"
    t.index ["eventable_id", "eventable_type"], name: "index_events_on_eventable_id_and_eventable_type"
    t.index ["fraction_id"], name: "index_events_on_fraction_id"
    t.index ["owner_id"], name: "index_events_on_owner_id"
    t.index ["slug"], name: "index_events_on_slug", unique: true
  end

  create_table "fractions", force: :cascade do |t|
    t.jsonb "name", default: {"en"=>"", "ru"=>""}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_fractions_on_name", using: :gin
  end

  create_table "guild_roles", force: :cascade do |t|
    t.integer "guild_id"
    t.integer "character_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guild_id", "character_id"], name: "index_guild_roles_on_guild_id_and_character_id", unique: true
  end

  create_table "guilds", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "world_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fraction_id"
    t.string "slug"
    t.index ["fraction_id"], name: "index_guilds_on_fraction_id"
    t.index ["name"], name: "index_guilds_on_name"
    t.index ["slug"], name: "index_guilds_on_slug", unique: true
    t.index ["world_id"], name: "index_guilds_on_world_id"
  end

  create_table "professions", force: :cascade do |t|
    t.jsonb "name", default: {"en"=>"", "ru"=>""}, null: false
    t.boolean "main", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "recipeable", default: false, null: false
    t.index ["name"], name: "index_professions_on_name", using: :gin
  end

  create_table "races", force: :cascade do |t|
    t.jsonb "name", default: {"en"=>"", "ru"=>""}, null: false
    t.integer "fraction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fraction_id"], name: "index_races_on_fraction_id"
    t.index ["name"], name: "index_races_on_name", using: :gin
  end

  create_table "recipes", force: :cascade do |t|
    t.integer "profession_id"
    t.integer "skill", default: 1, null: false
    t.jsonb "name", default: {"en"=>"", "ru"=>""}, null: false
    t.jsonb "links", default: {"en"=>"", "ru"=>""}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_recipes_on_name", using: :gin
    t.index ["profession_id"], name: "index_recipes_on_profession_id"
  end

  create_table "roles", force: :cascade do |t|
    t.jsonb "name", default: {"en"=>"", "ru"=>""}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", using: :gin
  end

  create_table "subscribes", force: :cascade do |t|
    t.integer "event_id"
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "unknown", null: false
    t.index ["event_id", "character_id"], name: "index_subscribes_on_event_id_and_character_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "worlds", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "zone", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_worlds_on_name"
  end

end
