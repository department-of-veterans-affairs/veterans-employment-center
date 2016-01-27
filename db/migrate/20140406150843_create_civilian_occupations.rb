class CreateCivilianOccupations < ActiveRecord::Migration
  def change
    create_table :civilian_occupations do |t|
      t.string :soc
      t.string :soc8
      t.string :title
      t.text :description
      t.timestamps
    end
    create_table :civilian_occupations_military_positions do |t|
      t.belongs_to :civilian_occupation
      t.belongs_to :military_position
    end
  end
end