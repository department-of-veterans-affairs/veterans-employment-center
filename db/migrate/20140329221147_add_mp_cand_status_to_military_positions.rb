class AddMpCandStatusToMilitaryPositions < ActiveRecord::Migration
  def change
    add_column :military_positions, :mpc, :string
    add_column :military_positions, :status, :string
  end
end
