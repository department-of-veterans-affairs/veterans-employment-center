class AddSourceToJobTitles < ActiveRecord::Migration
  def change
    add_column :job_titles, :source, :string
  end
end
