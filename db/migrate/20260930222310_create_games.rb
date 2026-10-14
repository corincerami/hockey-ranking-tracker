class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.bigint :season_id, null: false
      t.bigint :home_team_id, null: false
      t.bigint :away_team_id, null: false
      t.datetime :date
      t.string :game_type
      t.string :external_id
      t.timestamps

      t.index [ 'season_id' ], name: "index_games_on_season_id"
      t.index [ 'away_team_id' ], name: 'index_games_on_away_team_id'
      t.index [ 'home_team_id' ], name: 'index_games_on_home_team_id'
    end
  end
end
