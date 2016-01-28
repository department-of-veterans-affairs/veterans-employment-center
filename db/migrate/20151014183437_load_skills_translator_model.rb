# The initial MOC->Skill mapping needs to be loaded into the
# database in order to be used.

include MigrationHelper

class LoadSkillsTranslatorModel < ActiveRecord::Migration
  @@model_name = 'Initial Model from Bayes Impact'
  @@model_csv_path = 'db/seed/initial_skills_translator_model.csv'

  def change
    reversible do |change|
      change.up do
        moc_to_id = Hash[MilitaryOccupation.find_each.map {|m| [m.code, m.id]}]
        known_skill_ids = Set.new(Skill.find_each.map {|s| s.id})

        # Create a new model if it does not exist
        model = create_skills_translator_model(@@model_name)

        puts 'Loading CSV with initial skills translator model relevances'
        batch_size = 100000
        i = 0
        inserts = []
        @N =  `wc -l #{@@model_csv_path}`.to_i
        start = Time.now
        CSV.foreach(@@model_csv_path, headers: true) do |row|
          i += 1
          if not known_skill_ids.include? row['skill_id'].to_i
            #puts "#{i}: Skill id #{row['skill_id']} is unknown"
            next
          elsif not moc_to_id.include? row['moc']
            #puts "#{i}: MOC #{row['moc']} is unknown"
            next
          end
          inserts << [moc_to_id[row['moc']], row['skill_id'].to_i, row['relevance'].to_f]
          if inserts.length == batch_size
            mass_skills_translator_insert(inserts, model.id)
            puts "Inserted #{inserts.length} rows (#{i/1000}k/#{@N/1000}k total rows processed)"
            puts "#{(Time.now - start).to_i}s elapsed"
            inserts = []
          end
        end
        mass_skills_translator_insert(inserts, model.id)
        puts "Insertions complete. #{(Time.now - start).to_i}s elapsed\n\n"
        puts "** Be sure to set this environment variable to use this model **"
        puts "export SKILL_TRANSLATOR_MODEL_ID=#{model.id}"
        puts
      end

      change.down do
        destroy_skills_translator_model(@@model_name)
      end

    end
  end
end
