class RemoveCivilianOccupations < ActiveRecord::Migration
  def change
    drop_table :civilian_occupations
  end
end
