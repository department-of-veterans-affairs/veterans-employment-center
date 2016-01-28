class AddSourceToJobSkills < ActiveRecord::Migration
  def change
    add_column :job_skills, :source, :string
  end
end
