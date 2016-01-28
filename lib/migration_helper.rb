# Utility functions used in several migrations

module MigrationHelper
  def mass_skills_translator_insert(inserts, translator_model_id)
    # Given an array of [militrary_occupation_id, skill_id, relevance] arrays,
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
    # Finds and destroys the model with the given description
    # and its skill mapping records.
    # Returns true if successful, false if no model was found.
    model = SkillsTranslatorModel.where(description: desc).take
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
