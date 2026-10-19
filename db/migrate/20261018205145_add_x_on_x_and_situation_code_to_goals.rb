class AddXOnXAndSituationCodeToGoals < ActiveRecord::Migration[8.1]
  def change
    add_column :goals, :x_on_x, :string
    add_column :goals, :situation_code, :string
  end
end
