require 'rails_helper'

describe JobTitle do
  
  describe "job_title/deprecated_job_skill relationships" do

    context "when adding skills" do
      it "should be able to add skills to job, and get jobs from a skill" do
        job_title = JobTitle.create(code: '11-3031.00', name: 'Financial Managers')
        deprecated_job_skill = DeprecatedJobSkill.create(name: 'Banking', source: 'O*NET')
        job_title.deprecated_job_skills.push(deprecated_job_skill)
        expect(job_title.deprecated_job_skills.length).to eq 1
        expect(deprecated_job_skill.job_titles.length).to eq 1
      end
    end
  end 
end
