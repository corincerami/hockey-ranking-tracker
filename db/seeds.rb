require 'net/http'
require 'json'

season_uri = URI.parse("https://api.nhle.com/stats/rest/en/season")

season_response = Net::HTTP.get_response(season_uri)
JSON.parse(season_response.body)["data"].each do |season_data|
  Season.find_or_create_by!(
    name: season_data["formattedSeasonId"],
    start_date: season_data["startDate"],
    end_date: season_data["endDate"]
  )
end

FRANCHISES = [
  'NJD/CLR/KCS',
  'CAR/HFD',
  'BOS',
  'CBJ',
  'BUF',
  'DET/DFL/DCG',
  'NYI',
  'FLA',
  'NYR',
  'MTL',
  'PHI',
  'OTT',
  'PIT',
  'TBL',
  'WSH',
  'TOR/TSP/TAN',
  'CHI',
  'ANA',
  'COL/QUE',
  'CGY/AFM',
  'DAL/MNS',
  'EDM',
  'MIN',
  'LAK',
  'NSH',
  'SJS',
  'STL',
  'SEA',
  'UTA',
  'VAN',
  'WPG/ATL/WIN',
  'VGK',
  'CLE/CGS/OAK',
  'SLE/SEN',
  'HAM/QBD',
  'ARI/PHX',
  'MWN',
  'QUA/PIR',
  'BRK/NYA',
  'MMR',
  'VMA/VMI'
]

FRANCHISES.each do |name|
  Franchise.find_or_create_by!(name:)
end

team_uri = URI.parse("https://api.nhle.com/stats/rest/en/team")
team_response = Net::HTTP.get_response(team_uri)
JSON.parse(team_response.body)["data"].each do |team_data|
  next if [ "TBD" ].include?(team_data["rawTricode"])
  Team.find_or_create_by!(
    name: team_data["fullName"],
    external_id: team_data["id"],
    franchise: Franchise.all.detect { |franchise| franchise.name.include?(team_data["triCode"]) },
    code: team_data["triCode"]
  )
end

def period_name(data)
  # {"number"=>1, "periodType"=>"REG", "maxRegulationPeriods"=>3}
  if data["periodType"] == "REG"
    data["number"]
  elsif data["periodType"] == "OT"
    "OT#{data['number'] - 3}"
  end
end

def create_players_and_roster_spots(dataset, roster, game)
  dataset.each do |player_stats|
    player = Player.find_by(external_id: player_stats["playerId"])
    if player.nil?
      player_uri = URI.parse("https://api-web.nhle.com/v1/player/#{player_stats['playerId']}/landing")
      player_response = Net::HTTP.get_response(player_uri)
      next if player_response.body.starts_with?('<html')
      player_json = JSON.parse(player_response.body)
      name = player_json["firstName"]["default"] + " " + player_json["lastName"]["default"]
      player = Player.create!(external_id: player_stats["playerId"], name:)
    end
    RosterSpot.find_or_create_by(
      roster: roster,
      player:,
      jersey_number: player_stats["sweaterNumber"],
      position: player_stats["position"]
    )
  end
end

teams = Team.all.order(:code)
teams = teams.slice(ENV['SEED_INDEX'].to_i..) if ENV['SEED_INDEX'].present?
teams.each do |home_team|
  Rails.logger.info "Seeding #{home_team.code}"
  code = home_team.code == "UHC" ? "UTA" : home_team.code
  roster_seasons_uri = URI.parse("https://api-web.nhle.com/v1/roster-season/#{code}")
  roster_seasons_response = Net::HTTP.get_response(roster_seasons_uri)
  roster_seasons_json = JSON.parse(roster_seasons_response.body).map(&:to_s)
  if code == 'UTA' # the first season played as Utah Hockey Club doesn't get returned here
    roster_seasons_json.prepend('20242025')
  end
  roster_seasons_json.each do |season_name|
    formatted_name = "#{season_name.slice(0..3)}-#{season_name.slice(6..7)}"
    Rails.logger.info "  #{formatted_name}"
    next if formatted_name == "2026-27"
    season = Season.find_by(name: formatted_name)
    team_season_uri = URI.parse("https://api-web.nhle.com/v1/club-schedule-season/#{code}/#{season_name}")
    team_season_response = Net::HTTP.get_response(team_season_uri)
    JSON.parse(team_season_response.body)["games"].each do |game_data|
      next unless game_data["homeTeam"]["id"].to_s == home_team.external_id
      if [ 1, 2, 3 ].exclude? game_data['gameType']
        Rails.logger.info "Game #{game_data['id']} has type #{game_data['gameType']}"
      end
      next unless game_data["gameType"] == 2

      away_team = Team.find_by(external_id: game_data["awayTeam"]["id"])
      if away_team.nil? # non-NHL team like Vancouver Maroons
        away_team = Team.find_or_create_by!(
          name: game_data["awayTeam"]["placeName"]["default"] + " " + game_data["awayTeam"]["commonName"]["default"],
          external_id: game_data["awayTeam"]["id"],
          code: game_data["awayTeam"]["abbrev"]
        )
      end
      game = Game.find_or_create_by!(
        season:,
        home_team:,
        away_team:,
        date: Time.parse(game_data["startTimeUTC"]),
        game_type: 'regular_season',
        external_id: game_data["id"]
      )

      home_roster = Roster.find_or_create_by!(
        team: home_team,
        game:
      )

      away_roster = Roster.find_or_create_by!(
        team: away_team,
        game:
      )

      boxscore_uri = URI.parse("https://api-web.nhle.com/v1/gamecenter/#{game_data['id']}/boxscore")
      boxscore_response = Net::HTTP.get_response(boxscore_uri)
      boxscore_json = JSON.parse(boxscore_response.body)

      create_players_and_roster_spots(boxscore_json["playerByGameStats"]["awayTeam"]["forwards"], away_roster, game)
      create_players_and_roster_spots(boxscore_json["playerByGameStats"]["awayTeam"]["defense"], away_roster, game)
      create_players_and_roster_spots(boxscore_json["playerByGameStats"]["awayTeam"]["goalies"], away_roster, game)
      create_players_and_roster_spots(boxscore_json["playerByGameStats"]["homeTeam"]["forwards"], home_roster, game)
      create_players_and_roster_spots(boxscore_json["playerByGameStats"]["homeTeam"]["defense"], home_roster, game)
      create_players_and_roster_spots(boxscore_json["playerByGameStats"]["homeTeam"]["goalies"], home_roster, game)

      game_events_uri = URI.parse("https://api-web.nhle.com/v1/gamecenter/#{game.external_id}/play-by-play")
      game_events_response = Net::HTTP.get_response(game_events_uri)
      JSON.parse(game_events_response.body)["plays"].each do |event|
        if event["typeDescKey"] === "goal" && event["periodDescriptor"]["periodType"] != "SO"
          scoring_team = Team.find_by(external_id: event["details"]["eventOwnerTeamId"])
          goal = Goal.find_or_create_by!(
            game:,
            player: Player.find_by(external_id: event["details"]["scoringPlayerId"]),
            team: scoring_team,
            period: period_name(event["periodDescriptor"]),
            time_in_period: event["timeInPeriod"]
          )
          if event["details"]["assist1PlayerId"].present?
            Assist.find_or_create_by!(
              game:,
              goal:,
              primary: true,
              player: Player.find_by(external_id: event["details"]["assist1PlayerId"]),
              team: scoring_team,
              period: period_name(event["periodDescriptor"]),
              time_in_period: event["timeInPeriod"]
            )
          end
          if event["details"]["assist2PlayerId"].present?
            Assist.find_or_create_by(
              game:,
              goal:,
              primary: false,
              player: Player.find_by(external_id: event["details"]["assist2PlayerId"]),
              team: scoring_team,
              period: period_name(event["periodDescriptor"]),
              time_in_period: event["timeInPeriod"]
            )
          end
        end
      end
    end
  end
end

uhc = Team.find_by(name: "Utah Hockey Club")
mammoth = Team.find_by(name: "Utah Mammoth")

Game.where(away_team: uhc).update_all(away_team_id: mammoth.id)
Game.where(home_team: uhc).update_all(home_team_id: mammoth.id)
Goal.where(team: uhc).update_all(team_id: mammoth.id)
Roster.where(team: uhc).update_all(team_id: mammoth.id)
uhc.update(code: "UHC")

Team.nhl.each do |team|
  Ranker.new(scope: team, category: "goals").call
  Ranker.new(scope: team.franchise, category: "goals").call
  Ranker.new(scope: team, category: "assists").call
  Ranker.new(scope: team.franchise, category: "assists").call
end
Ranker.new(scope: nil, category: "goals").call
Ranker.new(scope: nil, category: "assists").call
