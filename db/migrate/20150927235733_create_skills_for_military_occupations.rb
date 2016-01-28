class CreateSkillsForMilitaryOccupations < ActiveRecord::Migration
  def change
    create_table :skills_for_military_occupations do |t|
      t.references :skills_translator_model, index: {name: "index_skills_for_moc_on_translator_model_id"}, null: false, foreign_key: true
      t.references :military_occupation, index: {name: "index_skills_for_moc_on_military_occupation_id"}, null: false, foreign_key: true
      t.references :skill, index: {name: "index_skills_for_moc_on_skill_id"}, null: false, foreign_key: true
      t.float :relevance, null: false

      t.timestamps null: false
    end
    add_index(:skills_for_military_occupations,
        [:skills_translator_model_id, :military_occupation_id, :skill_id],
        :unique => true,
        name: "index_for_uniqueness_on_all_fk_ids")
  end
end
