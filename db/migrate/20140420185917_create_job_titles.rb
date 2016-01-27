class CreateJobTitles < ActiveRecord::Migration
  def change
    create_table :job_titles do |t|
      t.string :code
      t.string :branch
      t.text :cached_result, limit: nil

      t.timestamps
    end
    add_index :job_titles, [:code, :branch]
  end
end
