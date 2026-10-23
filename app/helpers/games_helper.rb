module GamesHelper
  def stat_highlight(count_this_game, to_next_rank)
    if count_this_game >= to_next_rank
      "highlight-rank-up"
    elsif count_this_game > 0
      "highlight-progress"
    end
  end

  def stat_line_this_game(player:, goals_this_game:, assists_this_game:)
    copy = player.name
    if goals_this_game > 0 && assists_this_game > 0
      copy + ": #{goals_this_game}G #{assists_this_game}A #{goals_this_game + assists_this_game}P"
    elsif goals_this_game > 0
      copy + ": #{goals_this_game}G"
    elsif assists_this_game > 0
      copy + ": #{assists_this_game}A"
    else
      copy
    end
  end

  def stat_count_this_game(player:, game:, category:)
    count = if category == :goals
      game.goals.where(player:).count
    elsif category == :assists
      game.assists.where(player:).count
    elsif category == :points
      game.goals.where(player:).count + game.assists.where(player:).count
    end
    count if count > 0
  end
end
