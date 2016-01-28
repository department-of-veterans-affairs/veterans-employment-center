class SetShownSkillsDefaultValue < ActiveRecord::Migration
  def change
  	reversible do |change|
  		change.up do
  			change_column :skills_translator_events, :shown_skills, :text, :default => "[]"
  		end

  		change.down do
  			change_column :skills_translator_events, :shown_skills, :text, :default => nil
  		end
  	end
  end
end
