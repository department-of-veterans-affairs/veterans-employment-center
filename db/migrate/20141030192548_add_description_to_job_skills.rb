class AddDescriptionToJobSkills < ActiveRecord::Migration
  def change
    add_column :job_skills, :description, :text
  end
end
