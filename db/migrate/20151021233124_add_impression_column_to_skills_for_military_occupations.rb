class AddImpressionColumnToSkillsForMilitaryOccupations < ActiveRecord::Migration

	def change
		add_column :skills_for_military_occupations, :impressions, :decimal, default: 15.0
	end
end
