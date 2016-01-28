class CreateJobTitleMilitaryOccupations < ActiveRecord::Migration
  def change
    create_table :job_title_military_occupations do |t|
      t.integer :job_title_id
      t.integer :military_occupation_id

      t.timestamps
    end
  end
end
