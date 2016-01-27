include MigrationHelper

# Most of this is copied from load_skills_translator migration, so that we can
# have a new migration rather than editing a migraiton from the past
class AddDefaultSkills < ActiveRecord::Migration
  @@model_csv_path = 'db/seed/default_skills.csv'
  @@model_name = 'Initial Model from Bayes Impact'

  def change
      puts 'Importing default skills'

      # Create a default MOC
      MilitaryOccupation.find_or_create_by(code: 'DEFAULT', service: 'DEFAULT')

      # Create a new model if it does not exist
      model = create_skills_translator_model(@@model_name)
      moc_to_id = Hash[MilitaryOccupation.find_each.map {|m| [m.code, m.id]}]
      known_skill_ids = Set.new(Skill.find_each.map {|s| s.id})

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

      puts "Inserted #{inserts.length} default skills.\n\n"
  end
end
