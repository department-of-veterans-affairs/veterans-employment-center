class AddActiveToMilitaryOccupation < ActiveRecord::Migration
  def change
    add_column :military_occupations, :active, :boolean
  end
end
