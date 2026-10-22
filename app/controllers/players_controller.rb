class PlayersController < ApplicationController
  def show
    @player = Player.includes(:goals).find(params[:id])
  end
end
