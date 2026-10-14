class Rank < ApplicationRecord
  belongs_to :player
  belongs_to :scope, polymorphic: true, optional: true

  CATEGORIES = [
    "goals",
    "assists",
    "points"
  ]

  validates :category, inclusion: { in: CATEGORIES }

  def close_to_milestone?
    50 - (value % 50) < 4
  end
end
