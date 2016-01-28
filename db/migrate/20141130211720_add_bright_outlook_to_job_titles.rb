class AddBrightOutlookToJobTitles < ActiveRecord::Migration
  def change
    add_column :job_titles, :has_bright_outlook, :boolean
  end
end
