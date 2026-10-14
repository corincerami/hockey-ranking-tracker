class CreateGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :goals do |t|
      t.bigint :game_id, null: false
      t.bigint :player_id, null: false
      t.integer :team_id, null: false
      t.string :period
      t.string :time_in_period
      t.boolean :power_play
      t.boolean :short_handed
      t.boolean :empty_net
      t.boolean :own
      t.boolean :penalty_shot
      t.boolean :awarded
      t.boolean :game_winning
      t.timestamps

      t.index [ 'game_id' ], name: "index_goals_on_game_id"
      t.index [ 'player_id' ], name: "index_goals_on_player_id"
      t.index [ 'team_id' ], name: "index_goals_on_team_id"
    end
  end
end
