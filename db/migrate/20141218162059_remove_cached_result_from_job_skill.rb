class RemoveCachedResultFromJobSkill < ActiveRecord::Migration
  def change
    remove_column :job_skills, :cached_result, :text
  end
end
