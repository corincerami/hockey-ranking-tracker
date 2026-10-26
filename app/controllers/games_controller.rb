class GamesController < ApplicationController
  def index
    @date = date
    @games = Game.where(date: (date.beginning_of_day + 5.hours)...(date.end_of_day + 5.hours))
  end

  def show
    @game = Game.includes(goals: [ :team, :assists ]).find(params[:id])
    @team = params["team"] == "away" ? @game.away_team : @game.home_team
    @watcher = GameWatcher.new(game: @game).call
  end

  private

  def date
    params[:date].presence ? Date.parse(params[:date]) : Time.zone.now.to_date
  end
end
