class AddDescriptionToMilitaryPositions < ActiveRecord::Migration
  def change
    add_column :military_positions, :description, :text
  end
end
