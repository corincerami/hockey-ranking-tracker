class CreateUpcomingGamesJob < ApplicationJob
  # run each morning ~6am ET
  def perform
    (Date.today..1.week.from_now.to_date).each do |date|
      GamesByDateSeeder.new(date: date.to_s).call
    end
  end
end
