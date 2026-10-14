require "net/http"
require "json"

class GamesByDateSeeder
  attr_reader :date

  def initialize(date: Date.today.to_s)
    @date = date
  end

  def call
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)["games"].each do |game_data|
      GameSeeder.new(game_data:).call
    end
  end

  def uri
    URI.parse("https://api-web.nhle.com/v1/score/#{date}")
  end
end
