class CreateFranchises < ActiveRecord::Migration[8.1]
  def change
    create_table :franchises do |t|
      t.string :name
      t.timestamps
    end
  end
end

# Franchise
# - name
#
# Team
# - franchise
