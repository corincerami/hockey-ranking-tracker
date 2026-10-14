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

ActiveRecord::Schema[8.1].define(version: 2026_10_11_023630) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assists", force: :cascade do |t|
    t.bigint "goal_id", null: false
    t.bigint "game_id", null: false
    t.bigint "player_id", null: false
    t.boolean "primary", default: true, null: false
    t.integer "team_id", null: false
    t.string "period"
    t.string "time_in_period"
    t.boolean "power_play"
    t.boolean "short_handed"
    t.boolean "empty_net"
    t.boolean "own"
    t.boolean "penalty_shot"
    t.boolean "awarded"
    t.boolean "game_winning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_assists_on_game_id"
    t.index ["goal_id"], name: "index_assists_on_goal_id"
    t.index ["player_id"], name: "index_assists_on_player_id"
    t.index ["team_id"], name: "index_assists_on_team_id"
  end

  create_table "franchises", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.bigint "season_id", null: false
    t.bigint "home_team_id", null: false
    t.bigint "away_team_id", null: false
    t.datetime "date"
    t.string "game_type"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_team_id"], name: "index_games_on_away_team_id"
    t.index ["home_team_id"], name: "index_games_on_home_team_id"
    t.index ["season_id"], name: "index_games_on_season_id"
  end

  create_table "goals", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "player_id", null: false
    t.integer "team_id", null: false
    t.string "period"
    t.string "time_in_period"
    t.boolean "power_play"
    t.boolean "short_handed"
    t.boolean "empty_net"
    t.boolean "own"
    t.boolean "penalty_shot"
    t.boolean "awarded"
    t.boolean "game_winning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_goals_on_game_id"
    t.index ["player_id"], name: "index_goals_on_player_id"
    t.index ["team_id"], name: "index_goals_on_team_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ranks", force: :cascade do |t|
    t.integer "rank", null: false
    t.integer "value", null: false
    t.bigint "player_id", null: false
    t.string "category", null: false
    t.integer "scope_id"
    t.string "scope_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_ranks_on_player_id"
    t.index ["scope_id", "scope_type"], name: "index_ranks_on_scope_id_and_scope_type"
  end

  create_table "roster_spots", force: :cascade do |t|
    t.bigint "roster_id", null: false
    t.bigint "player_id", null: false
    t.string "jersey_number"
    t.string "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_roster_spots_on_player_id"
    t.index ["roster_id"], name: "index_roster_spots_on_roster_id"
  end

  create_table "rosters", force: :cascade do |t|
    t.integer "team_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_rosters_on_game_id"
    t.index ["team_id"], name: "index_rosters_on_team_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "franchise_id"
    t.index ["franchise_id"], name: "index_teams_on_franchise_id"
  end

  add_foreign_key "teams", "franchises"
end
