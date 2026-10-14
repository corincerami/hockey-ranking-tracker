class ScheduleGamesForTodayJob < ApplicationJob
  # run each morning ~6am ET
  def perform
    Game.today.each do |game|
      TrackGameJob.set(wait_until: game.date).perform_later(game.id)
    end
  end
end
