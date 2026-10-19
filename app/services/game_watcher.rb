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
    Player.joins(roster_spots: :roster).includes(:ranks).where(rosters: { team:, game: }).uniq
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
          goals: player.ranks.detect { |rank| rank.scope == nil && rank.category == "goals" },
          assists: player.ranks.detect { |rank| rank.scope == nil && rank.category == "assists" },
          points: player.ranks.detect { |rank| rank.scope == nil && rank.category == "points" }
        },
        franchise: {
          goals: player.ranks.detect { |rank| rank.scope_id == team.franchise_id && rank.category == "goals" },
          assists: player.ranks.detect { |rank| rank.scope_id == team.franchise_id && rank.category == "assists" },
          points: player.ranks.detect { |rank| rank.scope_id == team.franchise_id && rank.category == "points" }
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
