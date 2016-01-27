class CreateJobSkillMatches < ActiveRecord::Migration
  def change
    create_table :job_skill_matches do |t|
      t.integer :matchable_id
      t.string :matchable_type
      t.integer :job_skill_id

      t.timestamps
    end
  end
end
