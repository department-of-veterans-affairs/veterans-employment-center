class Skill < ActiveRecord::Base
  has_and_belongs_to_many :skills, join_table: :veteran_skills
end
