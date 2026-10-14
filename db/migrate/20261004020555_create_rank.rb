class CreateRank < ActiveRecord::Migration[8.1]
  def change
    create_table :ranks do |t|
      t.integer :rank, null: false
      t.integer :value, null: false
      t.bigint :player_id, null: false
      t.string :category, null: false
      t.integer :scope_id
      t.string :scope_type
      t.timestamps

      t.index [ :player_id ], name: "index_ranks_on_player_id"
      t.index [ :scope_id, :scope_type ], name: "index_ranks_on_scope_id_and_scope_type"
    end
  end
end
