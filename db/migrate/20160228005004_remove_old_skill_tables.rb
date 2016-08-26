class RemoveOldSkillTables < ActiveRecord::Migration
  def change
    drop_table :job_titles
    drop_table :job_title_military_occupations
    drop_table :deprecated_job_skills
    drop_table :deprecated_job_skill_matches
    remove_column :veterans, :deprecated_skills
  end
end
