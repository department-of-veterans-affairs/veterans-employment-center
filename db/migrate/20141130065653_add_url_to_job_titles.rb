class AddUrlToJobTitles < ActiveRecord::Migration
  def change
    add_column :job_titles, :url, :string
  end
end
