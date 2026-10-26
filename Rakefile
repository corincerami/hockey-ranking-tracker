# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

# 6 AM ET
task create_upcoming_games: [ :environment ] do
  (Time.zone.now.to_date..1.week.from_now.to_date).each do |date|
    GamesByDateSeeder.new(date: date.to_s).call
  end
end

# 3 AM ET
task rank_finished_games: [ :environment ] do
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

# 6 AM ET
task schedule_games_for_today: [ :environment ] do
  Game.today.each do |game|
    TrackGameJob.set(wait_until: game.date).perform_later(game.id)
  end
end
