class CreateJobSkills < ActiveRecord::Migration
  def change
    create_table :job_skills do |t|
      t.string :code, index: true
      t.text :cached_result, limit: nil

      t.timestamps
    end
  end
end
