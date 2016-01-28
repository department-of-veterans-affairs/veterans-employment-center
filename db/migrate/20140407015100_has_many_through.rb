class HasManyThrough < ActiveRecord::Migration
  def change
    drop_table :civilian_occupations_military_positions
  end
end
