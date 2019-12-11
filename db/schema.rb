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

ActiveRecord::Schema.define(version: 2019_12_11_204321) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "banks", force: :cascade do |t|
    t.integer "guild_id"
    t.string "name"
    t.integer "coins", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guild_id"], name: "index_banks_on_guild_id"
  end

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
    t.string "slug"
    t.integer "world_fraction_id"
    t.index ["character_class_id"], name: "index_characters_on_character_class_id"
    t.index ["guild_id"], name: "index_characters_on_guild_id"
    t.index ["name"], name: "index_characters_on_name"
    t.index ["race_id"], name: "index_characters_on_race_id"
    t.index ["slug"], name: "index_characters_on_slug"
    t.index ["user_id"], name: "index_characters_on_user_id"
    t.index ["world_fraction_id"], name: "index_characters_on_world_fraction_id"
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

  create_table "deliveries", force: :cascade do |t|
    t.integer "notification_id"
    t.integer "delivery_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "deliveriable_id"
    t.string "deliveriable_type"
    t.index ["deliveriable_id", "deliveriable_type", "notification_id"], name: "delivery_owner"
  end

  create_table "delivery_params", force: :cascade do |t|
    t.integer "delivery_id"
    t.jsonb "params", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_id"], name: "index_delivery_params_on_delivery_id"
    t.index ["params"], name: "index_delivery_params_on_params", using: :gin
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
    t.integer "world_fraction_id"
    t.index ["dungeon_id"], name: "index_events_on_dungeon_id"
    t.index ["eventable_id", "eventable_type"], name: "index_events_on_eventable_id_and_eventable_type"
    t.index ["fraction_id"], name: "index_events_on_fraction_id"
    t.index ["owner_id"], name: "index_events_on_owner_id"
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["world_fraction_id"], name: "index_events_on_world_fraction_id"
  end

  create_table "fractions", force: :cascade do |t|
    t.jsonb "name", default: {"en"=>"", "ru"=>""}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_fractions_on_name", using: :gin
  end

  create_table "group_roles", force: :cascade do |t|
    t.integer "groupable_id"
    t.string "groupable_type"
    t.jsonb "value", default: {"dd"=>{"amount"=>0, "by_class"=>{}}, "tanks"=>{"amount"=>0, "by_class"=>{}}, "healers"=>{"amount"=>0, "by_class"=>{}}}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "left_value"
    t.index ["groupable_id", "groupable_type"], name: "index_group_roles_on_groupable_id_and_groupable_type"
    t.index ["left_value"], name: "index_group_roles_on_left_value", using: :gin
    t.index ["value"], name: "index_group_roles_on_value", using: :gin
  end

  create_table "guild_invites", force: :cascade do |t|
    t.integer "guild_id"
    t.integer "character_id"
    t.boolean "from_guild", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["guild_id", "character_id", "from_guild"], name: "index_guild_invites_on_guild_id_and_character_id_and_from_guild", unique: true
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
    t.integer "world_fraction_id"
    t.text "description", default: "", null: false
    t.index ["fraction_id"], name: "index_guilds_on_fraction_id"
    t.index ["name"], name: "index_guilds_on_name"
    t.index ["slug"], name: "index_guilds_on_slug", unique: true
    t.index ["world_fraction_id"], name: "index_guilds_on_world_fraction_id"
    t.index ["world_id"], name: "index_guilds_on_world_id"
  end

  create_table "identities", force: :cascade do |t|
    t.integer "user_id"
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.index ["uid", "provider"], name: "index_identities_on_uid_and_provider"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.jsonb "name", default: {"en"=>"", "ru"=>""}, null: false
    t.string "event"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["name"], name: "index_notifications_on_name", using: :gin
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
    t.jsonb "effect_name", default: {"en"=>"", "ru"=>""}
    t.jsonb "effect_links", default: {"en"=>"", "ru"=>""}
    t.index ["name"], name: "index_recipes_on_name", using: :gin
    t.index ["profession_id"], name: "index_recipes_on_profession_id"
  end

  create_table "roles", force: :cascade do |t|
    t.jsonb "name", default: {"en"=>"", "ru"=>""}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", using: :gin
  end

  create_table "static_invites", force: :cascade do |t|
    t.integer "static_id"
    t.integer "character_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "from_static", default: true, null: false
    t.index ["static_id", "character_id", "from_static"], name: "static_invites_index", unique: true
    t.index ["status"], name: "index_static_invites_on_status"
  end

  create_table "static_members", force: :cascade do |t|
    t.integer "static_id"
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["static_id", "character_id"], name: "index_static_members_on_static_id_and_character_id", unique: true
  end

  create_table "statics", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "staticable_id"
    t.string "staticable_type"
    t.string "slug"
    t.text "description", default: "", null: false
    t.integer "fraction_id"
    t.integer "world_id"
    t.boolean "privy", default: true, null: false
    t.integer "world_fraction_id"
    t.index ["fraction_id"], name: "index_statics_on_fraction_id"
    t.index ["slug"], name: "index_statics_on_slug"
    t.index ["staticable_id", "staticable_type", "name"], name: "index_statics_on_staticable_id_and_staticable_type_and_name", unique: true
    t.index ["world_fraction_id"], name: "index_statics_on_world_fraction_id"
    t.index ["world_id"], name: "index_statics_on_world_id"
  end

  create_table "subscribes", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "comment"
    t.integer "status", default: 2, null: false
    t.integer "for_role"
    t.integer "subscribeable_id"
    t.string "subscribeable_type"
    t.index ["subscribeable_id", "subscribeable_type"], name: "index_subscribes_on_subscribeable_id_and_subscribeable_type"
  end

  create_table "time_offsets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_time_offsets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user", null: false
    t.string "remember_digest"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.string "reset_password_token"
    t.datetime "reset_password_token_sent_at"
    t.string "token"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "world_fractions", force: :cascade do |t|
    t.integer "world_id"
    t.integer "fraction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["world_id", "fraction_id"], name: "index_world_fractions_on_world_id_and_fraction_id"
  end

  create_table "worlds", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "zone", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_worlds_on_name"
  end

end
