class RenameOldSkillsColumn < ActiveRecord::Migration
  def change
    rename_column :veterans, :skills, :deprecated_skills
  end
end
