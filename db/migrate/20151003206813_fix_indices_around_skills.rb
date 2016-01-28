class FixIndicesAroundSkills < ActiveRecord::Migration
  def change
    remove_index :skills, :name
    add_index :skills, :name, unique: true
    add_index(:veteran_skills, [:veteran_id, :skill_id], unique: true)
  end
end
