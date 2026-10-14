class CreateSeasons < ActiveRecord::Migration[8.1]
  def change
    create_table :seasons do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :name
      t.timestamps
    end
  end
end
