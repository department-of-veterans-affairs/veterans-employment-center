# Seeds skills and creates initial skill translator model. 
# Only use this if you are getting an error like 'zero skills' 
# or 'Missing or bad ENV variable SKILLS_TRANSLATOR_MODEL_ID'
require 'csv'

namespace :db do
  desc 'Seeds base skills from LinkedIn'
  task :seed_skills => :environment do 
    ## WARNING WARNING THIS WILL DELETE ALL CURRENT SKILLS IN DATABASE
    ## Currently includes moderated list of LinkedIn skills
    ## To run: rake db:seed_skills
    ## Run this before :create_initial_model
    Skill.delete_all
    skills = CSV.read('db/seed/skills_corpus.csv', headers: true)
    ActiveRecord::Base.transaction do
      skills.each do |e|
        Skill.create(name: e['skill_name'], source: e['source'], belongs_to: e['belongs_to'], id: e['skill_id'])
        puts 'Imported a skill'
      end
    end
  end
  
  desc 'Creates initial model of skills relative to military occupations'
  task :create_initial_model => :environment do
    ## This file contains a curated list of most relevant skills, as an initial default for all MOCs
    ## To run: rake db:create_initial_model    
    @@model_csv_path = 'db/seed/default_skills.csv'
    ## You must change this name if you make a future model
    @@model_name = 'Initial model from LinkedIn'
    
    puts 'Importing default skills'

    # Create a default MOC
    MilitaryOccupation.find_or_create_by(code: 'DEFAULT', service: 'DEFAULT')

    # Create a new model if it does not exist
    model = create_skills_translator_model(@@model_name)
    moc_to_id = Hash[MilitaryOccupation.find_each.map {|m| [m.code, m.id]}]
    skill_to_id = Hash[Skill.find_each.map {|s| [s.name, s.id]}]

    batch_size = 100000
    i = 0
    inserts = []
    @N =  `wc -l #{@@model_csv_path}`.to_i
    start = Time.now
    CSV.foreach(@@model_csv_path, headers: true) do |row|
      i += 1
      if not skill_to_id.include? row['skill_name']
        #puts "#{i}: Skill name #{row['skill_name']} is unknown"
        next
      elsif not moc_to_id.include? row['moc']
        #puts "#{i}: MOC #{row['moc']} is unknown"
        next
      end
      inserts << [moc_to_id[row['moc']], skill_to_id[row['skill_name']], row['relevance'].to_f]
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
  
  def mass_skills_translator_insert(inserts, translator_model_id)
    # Given an array of [military_occupation_id, skill_id, relevance] arrays,
    # inserts them all into the skill mapping table with the given model id.
    return if inserts.empty?
    now = Time.now
    clauses = inserts.map do |m_id, s_id, rel|
      "(#{translator_model_id}, #{m_id}, #{s_id}, #{rel}, '#{now}', '#{now}')"
    end

    sql = %Q(
      INSERT INTO skills_for_military_occupations
      \(skills_translator_model_id, military_occupation_id, skill_id, relevance,
        created_at, updated_at\)
      VALUES
      #{clauses.join(",\n")}
      )
    ActiveRecord::Base.connection.execute(sql)
  end

  def create_skills_translator_model(desc)
    # Create a new model with the given description if it does not exist.
    # Returns the model.
    model = SkillsTranslatorModel.where(description: desc).take
    if model.nil?
      model = SkillsTranslatorModel.create(description: desc)
      puts "Created model '#{desc}' with id=#{model.id}"
    else
      puts "Model '#{desc}' already exists (id=#{model.id})"
    end
    return model
  end

  def destroy_skills_translator_model(desc)
    # Finds and destroys the model with the given description and its skill mapping records.
    # Returns true if successful, false if no model was found.
    model = SkillsTranslatorModel.where(id: desc).take
    if not model.nil?
      puts "Deleting skill mappings for model '#{desc}' (id=#{model.id})"
      ActiveRecord::Base.connection.execute(%Q(
        DELETE FROM skills_for_military_occupations
        WHERE skills_translator_model_id = #{model.id}))
      puts "Deleting model"
      model.destroy
      return true
    else
      puts "Model '#{desc}' does not exist"
      return false
    end
  end
  
end
