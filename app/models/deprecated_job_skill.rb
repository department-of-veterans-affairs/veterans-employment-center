class DeprecatedJobSkill < ActiveRecord::Base
  validates_uniqueness_of :code

  has_many :deprecated_job_skill_matches
  has_many :job_titles, through: :deprecated_job_skill_matches
  has_many :military_occupations, through: :deprecated_job_skill_matches
end