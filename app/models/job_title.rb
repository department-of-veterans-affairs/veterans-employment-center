class JobTitle < ActiveRecord::Base
  has_many :job_title_military_occupations
  has_many :military_occupations, through: :job_title_military_occupations

  has_many :deprecated_job_skill_matches, as: :matchable
  has_many :deprecated_job_skills, through: :deprecated_job_skill_matches

  def preparation_needed(military_occupation)
    jtmo = JobTitleMilitaryOccupation.find_by("job_title_id=? and military_occupation_id=?", self.id, military_occupation.id)
    jtmo.preparation_needed
  end

  def pay_grade(military_occupation)
    jtmo = JobTitleMilitaryOccupation.find_by("job_title_id=? and military_occupation_id=?", self.id, military_occupation.id)
    jtmo.pay_grade
  end
end