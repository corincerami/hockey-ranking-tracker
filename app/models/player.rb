class Player < ApplicationRecord
  has_many :goals, dependent: :destroy
  has_many :assists, dependent: :destroy
  has_many :roster_spots, dependent: :destroy
  has_many :rosters, through: :roster_spots
  has_many :teams, through: :rosters
  has_many :ranks
end
