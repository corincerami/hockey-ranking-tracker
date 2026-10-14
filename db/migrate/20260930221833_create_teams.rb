class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :code
      t.string :external_id
      t.timestamps
    end
  end
end
