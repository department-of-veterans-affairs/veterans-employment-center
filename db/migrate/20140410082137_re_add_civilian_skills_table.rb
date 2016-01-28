class ReAddCivilianSkillsTable < ActiveRecord::Migration
  def change
    create_table :civilian_skills do |t|
      t.string :soc
      t.string :skill
      t.timestamps
    end
  end
end
