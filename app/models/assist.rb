class Assist < ApplicationRecord
  belongs_to :goal
  belongs_to :game
  belongs_to :player
  belongs_to :team

  scope :primary, -> { where(primary: true) }
  scope :secondary, -> { where(primary: false) }
end
