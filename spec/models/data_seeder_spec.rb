require 'rails_helper'
require 'rake'

describe 'Data Seeding' do

  context "before seeding the DB" do
    it "should have no data in relevant DB tables" do
      expect DeprecatedJobSkill.all.empty?
      expect JobTitle.all.empty?
      expect MilitaryOccupation.all.empty?
    end
  end

  context "after seeding the DB" do
    before do
      load Rails.root + "db/seeds.rb"
    end

    it "should seed the job_titles, deprecated_job_skills, military_occupations, deprecated_job_skill_matches, and job_title_military_occupations tables" do
      expect JobTitle.all.size > 0
      expect MilitaryOccupation.all.size > 0
      expect DeprecatedJobSkill.all.size > 0
      expect DeprecatedJobSkillMatch.all.size > 0
      expect JobTitleMilitaryOccupation.all.size > 0
    end
  end
end
