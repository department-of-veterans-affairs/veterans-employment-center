require 'rails_helper'

describe SiteFeedback do

  it "should not be created without a description" do
    site_feedback = SiteFeedback.new
    expect(site_feedback).to be_invalid
  end

  it "should be created when provided with at least a description" do
    site_feedback = SiteFeedback.new(description: "This is a description")
    expect(site_feedback).to be_valid
  end

end
