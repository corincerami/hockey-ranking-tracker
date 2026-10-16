class Ranker
  attr_reader :scope, :category

  def initialize(scope:, category:)
    @scope = scope
    @category = category
  end

  def call
    delete_existing_ranks
    rank = 1
    next_rank = nil
    players_by_count.each do |data|
      count, players = data
      next_rank_rank = next_rank&.rank
      to_next_rank = (next_rank.value - count) if next_rank
      players.each do |player|
        next_rank = Rank.create!(
          rank:,
          value: count,
          player:,
          category:,
          scope: scope,
          next_rank: next_rank_rank,
          to_next_rank:
        )
      end
      rank += players.length
    end
  end

  def delete_existing_ranks
    Rank.where(scope:, category:).delete_all
  end

  def players_by_count
    if category == "points"
      players_by_point_count
    else
      players_by_stat_count
    end
  end

  def players_by_stat_count
    query = Player.left_outer_joins(category.to_sym)

    query = query.where(category.to_sym => { team: teams }) if scope

    result = query.group("players.id")
      .select("players.*", "COUNT(#{category}.id) AS stat_count")
      .order("stat_count DESC")
      .group_by(&:stat_count)

    players_with_zero_stat_in_scope = Player
      .joins(roster_spots: :roster)
      .where(rosters: { team: teams })
      .where.not(id: result.values.flatten.map(&:id)).uniq

    result[0] = players_with_zero_stat_in_scope unless scope.nil?
    result
  end

  def players_by_point_count
    query = Player.left_outer_joins(:goals, :assists)

    query = query.where(goals: { team: teams }, assists: { team: teams }) if scope

    result = query
      .group("players.id")
      .select("players.*", "COUNT(DISTINCT(goals.id)) AS goals_count", "COUNT(DISTINCT(assists.id)) AS assists_count")
      .group_by { |player| player.goals_count + player.assists_count }
      .sort_by { |k, v| k }.reverse.to_h

    players_with_no_points = Player.joins(roster_spots: :roster)
      .where(rosters: { team: teams })
      .where.not(id: result.values.flatten.map(&:id)).uniq

    result[0] = players_with_no_points unless scope.nil?
    result
  end

  def teams
    @_teams ||= if scope.is_a?(Franchise)
      scope.teams
    elsif scope.is_a?(Team)
      scope
    elsif scope.nil?
      Team.all
    else
      raise "Invalid scope"
    end
  end
end
