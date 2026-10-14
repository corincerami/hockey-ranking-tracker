class GameWatcher
  attr_reader :game, :home_team, :away_team

  def initialize(game:)
    @game = game
    @home_team = game.home_team
    @away_team = game.away_team
  end

  def call
    {
      home_team: {
        team: home_team,
        data: upcoming_ranks(home_team)
      },
      away_team: {
        team: away_team,
        data: upcoming_ranks(away_team)
      }
    }
  end

  def team_players(team)
    game.roster_spots.includes(:player).where(rosters: { team: }).map(&:player)
  end

  def upcoming_ranks(team)
    players = team_players(team)
    players.map { |player|
      data_for_player(player, team)
    }.sort_by { |data| highest_rank(data) }
  end

  def data_for_player(player, team)
    {
      player:,
      team:,
      data: {
        all_time: {
          goals: UpcomingRankFinder.new(player:, scope: nil, category: "goals"),
          assists: UpcomingRankFinder.new(player:, scope: nil, category: "assists"),
          points: UpcomingRankFinder.new(player:, scope: nil, category: "points")
        },
        # team: {
        #   goals: UpcomingRankFinder.new(player:, scope: team, category: "goals"),
        #   assists: UpcomingRankFinder.new(player:, scope: team, category: "assists")
        # },
        franchise: {
          goals: UpcomingRankFinder.new(player:, scope: team.franchise, category: "goals"),
          assists: UpcomingRankFinder.new(player:, scope: team.franchise, category: "assists"),
          points: UpcomingRankFinder.new(player:, scope: team.franchise, category: "points")
        }
      }
    }
  end

  def highest_rank(data)
    [
      data[:data][:franchise][:goals].current_rank&.rank.to_i,
      data[:data][:all_time][:goals].current_rank&.rank.to_i,
      data[:data][:franchise][:assists].current_rank&.rank.to_i,
      data[:data][:all_time][:assists].current_rank&.rank.to_i,
      data[:data][:franchise][:points].current_rank&.rank.to_i,
      data[:data][:all_time][:points].current_rank&.rank.to_i
    ].min # add other categories
  end
end
