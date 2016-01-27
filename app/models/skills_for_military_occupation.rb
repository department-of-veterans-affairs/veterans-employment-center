class SkillsForMilitaryOccupation < ActiveRecord::Base
  belongs_to :skills_translator_model
  belongs_to :military_occupation
  belongs_to :skill

  def self.get_skills(model, military_occupation)
    SkillsForMilitaryOccupation.select(
      'skills.id', 'skills.name', :relevance).joins(
      'LEFT JOIN skills on skills.id = skills_for_military_occupations.skill_id').where(
      military_occupation_id: military_occupation.id,
      skills_translator_model_id: model.id).order(relevance: :desc)
  end
end
