class TrackGameJob < ApplicationJob
  def perform(game_id)
    game = Game.find(game_id)

    uri = URI.parse("https://api-web.nhle.com/v1/gamecenter/#{game.external_id}/boxscore")
    response = Net::HTTP.get_response(uri)
    game_data = JSON.parse(response.body)

    GameSeeder.new(game_data).call

    if game_data["gameState"] == "LIVE"
      TrackGameJob.set(wait_until: 30.seconds.from_now).perform_later(game.id)
    end
  end
end
