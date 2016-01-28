class DeprecatedJobSkillMatch < ActiveRecord::Base
	belongs_to :deprecated_job_skill
	belongs_to :matchable, polymorphic: true
	belongs_to :job_title, foreign_key: :matchable_id, class_name: 'JobTitle'
	belongs_to :military_occupation, foreign_key: :matchable_id, class_name: 'MilitaryOccupation'

	validates_presence_of :matchable_id, :message => "matchable id required"
	validates_presence_of :matchable_type, :message => "matchable type required"
	validates :matchable_type, inclusion: {in: ['JobTitle', 'MilitaryOccupation'], message: "%{value} must be JobTitle or MilitaryOccupation"}
end