require 'rails_helper'

describe DeprecatedJobSkillMatch do

  it "should not be created without required fields" do
    deprecated_job_skill_match = DeprecatedJobSkillMatch.new
    expect(deprecated_job_skill_match).to be_invalid
  end

end
