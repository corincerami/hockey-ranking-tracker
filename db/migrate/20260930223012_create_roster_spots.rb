class CreateRosterSpots < ActiveRecord::Migration[8.1]
  def change
    create_table :roster_spots do |t|
      t.bigint :roster_id, null: false
      t.bigint :player_id, null: false
      t.string :jersey_number
      t.string :position
      t.timestamps

      t.index [ 'roster_id' ], name: "index_roster_spots_on_roster_id"
      t.index [ 'player_id' ], name: "index_roster_spots_on_player_id"
    end
  end
end
