class AddIndexToMilitaryPositions < ActiveRecord::Migration
  def change
    add_index :military_positions, :code
  end
end
