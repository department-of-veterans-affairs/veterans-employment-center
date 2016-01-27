class AddIndexOnJobSkillsCode < ActiveRecord::Migration
  def change
    add_index :job_skills, :code
  end
end
