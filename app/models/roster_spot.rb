class RosterSpot < ApplicationRecord
  belongs_to :roster
  belongs_to :player

  delegate :team, to: :roster
  delegate :game, to: :roster
  delegate :season, to: :game
end
