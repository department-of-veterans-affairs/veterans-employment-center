include MigrationHelper

class CreateDummySkillsTranslator < ActiveRecord::Migration

  @@model_name = 'Dummy model based on old O*NET mapping'

  def change
    reversible do |change|
      change.up do
        model = create_skills_translator_model(@@model_name)
        sql = %Q(
          select a.matchable_id as military_occupation_id, c.id as skill_id
          from deprecated_job_skill_matches a
          join deprecated_job_skills b
          ON a.deprecated_job_skill_id = b.id
          join skills c
          ON b.name = c.name
          WHERE a.matchable_type = 'MilitaryOccupation'
        )
        inserts = ActiveRecord::Base.connection.execute(sql).map do |row|
          [row['military_occupation_id'], row['skill_id'], 1.0]
        end
        mass_skills_translator_insert(inserts.uniq, model.id)
      end

      change.down do
        destroy_skills_translator_model(@@model_name)
      end

    end
  end
end
