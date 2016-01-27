class AddNameToJobSkills < ActiveRecord::Migration
  def change
    add_column :job_skills, :name, :string
  end
end
