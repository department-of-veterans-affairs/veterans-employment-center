class AddDescriptionToJobTitles < ActiveRecord::Migration
  def change
    add_column :job_titles, :description, :text
  end
end
