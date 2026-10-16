class AddNextRankAndToNextRankToRanks < ActiveRecord::Migration[8.1]
  def change
    add_column :ranks, :next_rank, :integer
    add_column :ranks, :to_next_rank, :integer
  end
end
