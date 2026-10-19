class AddXOnXAndSituationCodeToAssists < ActiveRecord::Migration[8.1]
  def change
    add_column :assists, :x_on_x, :string
    add_column :assists, :situation_code, :string
  end
end
