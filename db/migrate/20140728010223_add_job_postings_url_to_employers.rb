class AddJobPostingsUrlToEmployers < ActiveRecord::Migration
  def change
    add_column :employers, :job_postings_url, :text
  end
end
