class DropForeignKeys < ActiveRecord::Migration
  def change
    remove_foreign_key "skills", name: "fk_rails_9300e20523"
    remove_foreign_key "skills_for_military_occupations", "military_occupations"
    remove_foreign_key "skills_for_military_occupations", "skills"
    remove_foreign_key "skills_for_military_occupations", "skills_translator_models"
    remove_foreign_key "skills_translator_events", "skills"
    remove_foreign_key "skills_translator_sessions", "skills_translator_models"
    remove_foreign_key "veteran_skills", "skills"
    remove_foreign_key "veteran_skills", "veterans"
  end
end
