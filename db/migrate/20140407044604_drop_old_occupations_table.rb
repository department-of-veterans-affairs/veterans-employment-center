class DropOldOccupationsTable < ActiveRecord::Migration
  def change
  	return
    drop_table :civilian_occupations_skills
  end
end
