class RankFinishedGamesJob < ApplicationJob
  # run each night ~3am ET
  def perform
    GamesByDateSeeder.new(date: Date.yesterday.to_s).call

    Team.nhl.each do |team|
      Ranker.new(scope: team, category: "goals").call
      Ranker.new(scope: team.franchise, category: "goals").call
      Ranker.new(scope: team, category: "assists").call
      Ranker.new(scope: team.franchise, category: "assists").call
      Ranker.new(scope: team, category: "points").call
      Ranker.new(scope: team.franchise, category: "points").call
    end
    Ranker.new(scope: nil, category: "goals").call
    Ranker.new(scope: nil, category: "assists").call
    Ranker.new(scope: nil, category: "points").call
  end
end
