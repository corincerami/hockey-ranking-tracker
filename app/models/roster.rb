class Roster < ApplicationRecord
  belongs_to :team
  belongs_to :game

  has_many :roster_spots
end
