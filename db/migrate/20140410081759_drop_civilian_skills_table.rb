class DropCivilianSkillsTable < ActiveRecord::Migration
  def change
    drop_table :civilian_skills
  end
end
