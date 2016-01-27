require 'rails_helper'

describe MilitaryOccupation do
  it "should be able to accept valid deprecated_job_skill associations" do
    deprecated_job_skill = DeprecatedJobSkill.create(code: 'x', name: 'Test SKill', description: 'A test skill')
    mo = MilitaryOccupation.create(code: '11b', service: 'Army')
    mo.deprecated_job_skills << deprecated_job_skill
    expect(mo.deprecated_job_skills.length).to eq 1
  end
   it "should be able to accept valid job_title associations" do
    job_titles = JobTitle.create(code: 'y', name: 'Test Title', description: 'A test job title')
    mo = MilitaryOccupation.create(code: '11b', service: 'Coast Guard')
    mo.job_titles << job_titles
    expect(mo.job_titles.length).to eq 1
  end
end
