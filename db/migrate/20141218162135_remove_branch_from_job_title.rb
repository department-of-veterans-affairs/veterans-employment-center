class RemoveBranchFromJobTitle < ActiveRecord::Migration
  def change
    remove_column :job_titles, :branch, :string
  end
end
