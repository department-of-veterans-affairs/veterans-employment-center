class AddIsGreenToJobTitles < ActiveRecord::Migration
  def change
    add_column :job_titles, :is_green, :boolean
  end
end
