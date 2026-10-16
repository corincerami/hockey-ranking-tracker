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
          goals: Rank.find_by(player:, scope: nil, category: "goals"),
          assists: Rank.find_by(player:, scope: nil, category: "assists"),
          points: Rank.find_by(player:, scope: nil, category: "points")
        },
        # team: {
        #   goals: UpcomingRankFinder.new(player:, scope: team, category: "goals"),
        #   assists: UpcomingRankFinder.new(player:, scope: team, category: "assists")
        # },
        franchise: {
          goals: Rank.find_by(player:, scope: team.franchise, category: "goals"),
          assists: Rank.find_by(player:, scope: team.franchise, category: "assists"),
          points: Rank.find_by(player:, scope: team.franchise, category: "points")
        }
      }
    }
  end

  def highest_rank(data)
    [
      data[:data][:franchise][:goals].rank.to_i,
      data[:data][:all_time][:goals].rank.to_i,
      data[:data][:franchise][:assists].rank.to_i,
      data[:data][:all_time][:assists].rank.to_i,
      data[:data][:franchise][:points].rank.to_i,
      data[:data][:all_time][:points].rank.to_i
    ].min # add other categories
  end
end
