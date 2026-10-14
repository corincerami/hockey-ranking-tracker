class UpcomingRankFinder
  attr_reader :player, :scope, :category

  def initialize(player:, scope:, category:)
    @player = player
    @scope = scope
    @category = category
  end

  def current_rank
    @current_rank ||= Rank.find_by(player:, scope:, category:)
  end

  def next_ranks
    if current_rank.rank != 1
      return @next_ranks if defined?(@next_ranks)
      next_rank = Rank.includes(:player)
        .where(scope:, category:, rank: ..(current_rank.rank - 1))
        .order(rank: :asc)
        .last.rank
      @next_ranks ||= Rank.includes(:player).where(scope:, category:, rank: next_rank)
    else
      Rank.none
    end
  end

  def players_at_next_rank
    next_ranks.map(&:player)
  end

  def next_rank_value
    next_ranks.first&.value
  end

  def to_next_rank
    if next_rank_value.present?
      next_rank_value - current_rank.value
    end
  end
end
