class ModifyCivilianOccupations < ActiveRecord::Migration
  def up
    drop_table :civilian_occupations
    create_table :civilian_occupations do |t|
      t.string :soc8
      t.text :cached_result
      t.timestamps
    end
    add_index :civilian_occupations, :soc8
  end
  
  def down
    drop_table :civilian_occupations
    create_table "civilian_occupations" do |t|
      t.string   "soc"
      t.string   "soc8"
      t.string   "title"
      t.text     "description"
      t.timestamps
    end
    add_index :civilian_occupations, :soc8
  end
end
