class CreateRosters < ActiveRecord::Migration[8.1]
  def change
    create_table :rosters do |t|
      t.integer :team_id, null: false
      t.bigint :game_id, null: false
      t.timestamps

      t.index [ 'team_id' ], name: "index_rosters_on_team_id"
      t.index [ 'game_id' ], name: "index_rosters_on_game_id"
    end
  end
end
