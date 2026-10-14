class Game < ApplicationRecord
  belongs_to :season
  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"

  has_many :rosters, dependent: :destroy
  has_many :roster_spots, through: :rosters, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :assists, dependent: :destroy

  scope :today, -> {
    where(date: Date.today.in_time_zone("Pacific Time (US & Canada)").beginning_of_day...Date.today.in_time_zone("Pacific Time (US & Canada)").end_of_day)
  }
end
