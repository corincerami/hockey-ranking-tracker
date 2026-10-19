class GoalsSeeder
  attr_reader :game

  def initialize(game:)
    @game = game
  end

  def call
    if game.date.past?
      game.goals.delete_all
      game.assists.delete_all
      create_goals
    end
  end

  def create_goals
    game_events_uri = URI.parse("https://api-web.nhle.com/v1/gamecenter/#{game.external_id}/landing")
    game_events_response = Net::HTTP.get_response(game_events_uri)
    JSON.parse(game_events_response.body)["summary"]["scoring"].reject { |period|
      period["periodDescriptor"]["periodType"] == "SO"
    }.each do |period|
      period["goals"].each do |goal_data|
        team = goal_data["isHome"] ? game.home_team : game.away_team
        goal = Goal.create!(
          game:,
          player: Player.find_by(external_id: goal_data["playerId"]),
          team:,
          period: period["periodDescriptor"]["periodType"] == "OT" ? "OT1" : period["periodDescriptor"]["number"],
          time_in_period: goal_data["timeInPeriod"],
          situation_code: goal_data["situationCode"],
          x_on_x: x_on_x(goal_data),
          power_play: goal_data["strength"] == "pp",
          short_handed: goal_data["strength"] == "sh",
          empty_net: empty_net?(goal_data),
          own: goal_data["goalModifier"].include?("own"),
          penalty_shot: goal_data["goalModifier"].include?("penalty-shot"),
          awarded: goal_data["goalModifier"].include?("awarded")
        )
        goal_data["assists"].each_with_index do |assist_data, index|
          Assist.create!(
            game:,
            goal:,
            primary: index == 0,
            player: Player.find_by(external_id: assist_data["playerId"]),
            team:,
            period: goal.period,
            time_in_period: goal.time_in_period,
            situation_code: goal.situation_code,
            x_on_x: goal.x_on_x,
            power_play: goal.power_play?,
            short_handed: goal.short_handed?,
            empty_net: goal.empty_net?,
            own: goal.own?,
            penalty_shot: goal.penalty_shot?,
            awarded: goal.awarded?
          )
        end
      end
    end
  end

  def x_on_x(goal_data)
    situation_code = goal_data["situationCode"]
    return '' if situation_code.nil?
    home_players = situation_code[2].to_i
    away_players = situation_code[1].to_i
    if goal_data['isHome']
      "#{home_players}-on-#{away_players}"
    else
      "#{away_players}-on-#{home_players}"
    end
  end

  def empty_net?(goal_data)
    situation_code = goal_data["situationCode"]
    return if situation_code.nil?
    if goal_data['isHome']
      situation_code[0] == '0'
    else
      situation_code[3] == '0'
    end
  end
end