class AddNameToJobTitles < ActiveRecord::Migration
  def change
    add_column :job_titles, :name, :string
  end
end
