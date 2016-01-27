class RemoveCachedResultFromJobTitle < ActiveRecord::Migration
  def change
    remove_column :job_titles, :cached_result, :text
  end
end
