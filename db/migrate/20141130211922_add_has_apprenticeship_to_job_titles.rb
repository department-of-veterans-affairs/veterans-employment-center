class AddHasApprenticeshipToJobTitles < ActiveRecord::Migration
  def change
    add_column :job_titles, :has_apprenticeship, :boolean
  end
end
