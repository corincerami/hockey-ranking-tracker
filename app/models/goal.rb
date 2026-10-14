class Goal < ApplicationRecord
  belongs_to :game
  belongs_to :player
  belongs_to :team

  has_many :assists, dependent: :destroy
end
