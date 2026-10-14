class Team < ApplicationRecord
  belongs_to :franchise, optional: true

  has_many :rosters
  has_many :roster_spots, through: :rosters
  has_many :players, through: :roster_spots

  CURRENT_NHL_TEAMS = [
    "ANA",
    "BOS",
    "BUF",
    "CAR",
    "CBJ",
    "CGY",
    "CHI",
    "COL",
    "DAL",
    "DET",
    "EDM",
    "FLA",
    "LAK",
    "MIN",
    "MTL",
    "NJD",
    "NSH",
    "NYI",
    "NYR",
    "OTT",
    "PHI",
    "PIT",
    "SEA",
    "SJS",
    "STL",
    "TBL",
    "TOR",
    "UTA",
    "VAN",
    "VGK",
    "WPG",
    "WSH"
  ]

  scope :nhl, -> { where(code: CURRENT_NHL_TEAMS) }
end
