class GameSeeder
  attr_reader :game_data

  def initialize(game_data:)
    @game_data = game_data
  end

  def call
    create_players
    create_goals
  end

  def home_team
    @home_team ||= Team.find_by(external_id: game_data["homeTeam"]["id"])
  end

  def home_roster
    @home_roster ||= Roster.find_or_create_by!(
      team: home_team,
      game:
    )
  end

  def away_team
    @away_team ||= Team.find_by(external_id: game_data["awayTeam"]["id"])
  end

  def away_roster
    @away_roster ||= Roster.find_or_create_by!(
      team: away_team,
      game:
    )
  end

  def season
    season_years = game_data["season"].to_s
    formatted_name = "#{season_years.slice(0..3)}-#{season_years.slice(6..7)}"
    @season ||= Season.find_by(name: formatted_name)
  end

  def game
    @game ||= Game.find_or_create_by!(
      season:,
      home_team:,
      away_team:,
      date: Time.parse(game_data["startTimeUTC"]),
      game_type: "regular_season",
      external_id: game_data["id"]
    )
  end

  def create_players
    RosterSpot.where(roster: [ home_roster, away_roster ]).delete_all
    if game.date.past?
      create_players_past_or_current_game
    else
      create_players_upcoming_game
    end
  end

  def create_players_past_or_current_game
      uri = URI.parse("https://api-web.nhle.com/v1/gamecenter/#{game_data['id']}/boxscore")
      response = Net::HTTP.get_response(uri)
      json = JSON.parse(response.body)

      home_players = json["playerByGameStats"]["homeTeam"]["forwards"] +
        json["playerByGameStats"]["homeTeam"]["defense"] +
        json["playerByGameStats"]["homeTeam"]["goalies"]

      away_players = json["playerByGameStats"]["awayTeam"]["forwards"] +
        json["playerByGameStats"]["awayTeam"]["defense"] +
        json["playerByGameStats"]["awayTeam"]["goalies"]

      home_players.each do |player_stats|
        player = create_player(player_stats)

        RosterSpot.create!(
          roster: home_roster,
          player:,
          jersey_number: player_stats["sweaterNumber"],
          position: player_stats["position"]
        )
      end
      away_players.each do |player_stats|
        player = create_player(player_stats)

        RosterSpot.create!(
          roster: away_roster,
          player:,
          jersey_number: player_stats["sweaterNumber"],
          position: player_stats["position"]
        )
      end
  end

  def create_players_upcoming_game
    uri = URI.parse("https://api-web.nhle.com/v1/gamecenter/#{game_data['id']}/landing")
    response = Net::HTTP.get_response(uri)
    json = JSON.parse(response.body)
    (json["matchup"]["skaterSeasonStats"]["skaters"] + json["matchup"]["goalieSeasonStats"]["goalies"]).each do |player_data|
      position = player_data["savePctg"].present? ? "G" : player_data["position"]
      player = create_player(player_data)
      roster = if player_data["teamId"].to_s == home_team.external_id.to_s
        home_roster
      elsif player_data["teamId"].to_s == away_team.external_id.to_s
        away_roster
      else
        raise "Player with NHL ID #{player_data["playerId"]} doesn't belong to either team!"
      end

      RosterSpot.create!(
        roster:,
        player:,
        jersey_number: player_data["sweaterNumber"],
        position:
      )
    end
  end

  def create_player(player_stats)
    player = Player.find_by(external_id: player_stats["playerId"])
    if player.nil?
      player_uri = URI.parse("https://api-web.nhle.com/v1/player/#{player_stats['playerId']}/landing")
      player_response = Net::HTTP.get_response(player_uri)
      return if player_response.body.starts_with?("<html")
      player_json = JSON.parse(player_response.body)
      name = player_json["firstName"]["default"] + " " + player_json["lastName"]["default"]
      player = Player.create!(external_id: player_stats["playerId"], name:)
    end
    player
  end

  def period_name(data)
    # {"number"=>1, "periodType"=>"REG", "maxRegulationPeriods"=>3}
    if data["periodType"] == "REG"
      data["number"]
    elsif data["periodType"] == "OT"
      "OT#{data['number'] - 3}"
    end
  end

  def create_goals
    if game.date.past?
      game.goals.delete_all
      game.assists.delete_all
      game_events_uri = URI.parse("https://api-web.nhle.com/v1/gamecenter/#{game.external_id}/play-by-play")
      game_events_response = Net::HTTP.get_response(game_events_uri)
      JSON.parse(game_events_response.body)["plays"].each do |event|
        if event["typeDescKey"] === "goal" && event["periodDescriptor"]["periodType"] != "SO"
          team = Team.find_by(external_id: event["details"]["eventOwnerTeamId"])
          goal = Goal.create!(
            game:,
            player: Player.find_by(external_id: event["details"]["scoringPlayerId"]),
            team:,
            period: period_name(event["periodDescriptor"]),
            time_in_period: event["timeInPeriod"]
          )
          if event["details"]["assist1PlayerId"].present?
            Assist.create!(
              game:,
              goal:,
              primary: true,
              player: Player.find_by(external_id: event["details"]["assist1PlayerId"]),
              team:,
              period: period_name(event["periodDescriptor"]),
              time_in_period: event["timeInPeriod"]
            )
          end
          if event["details"]["assist2PlayerId"].present?
            Assist.create!(
              game:,
              goal:,
              primary: false,
              player: Player.find_by(external_id: event["details"]["assist2PlayerId"]),
              team:,
              period: period_name(event["periodDescriptor"]),
              time_in_period: event["timeInPeriod"]
            )
          end
        end
      end
    end
  end
end
