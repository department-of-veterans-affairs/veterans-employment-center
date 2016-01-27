class AddIndexOnCivilianOccupationsSoc8 < ActiveRecord::Migration
  def change
    add_index :civilian_occupations, :soc8
  end
end
