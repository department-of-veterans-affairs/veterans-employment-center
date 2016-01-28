class CreateVeteranSkills < ActiveRecord::Migration
  def change
    create_table :veteran_skills, id: false do |t|
      t.references :veteran, foreign_key: true
      t.references :skill, foreign_key: true
    end
  end
end
