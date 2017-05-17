require 'rails_helper'

describe "Job Search Query" do
  context "when nil and empty string values are given for query string parameters" do
    before do
      stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=0&query=java%20jobs%20&size=11").
        to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/jobs_api/empty.json"), headers: {})
      stub_request(:get, "http://api2.us.jobs/?key=#{ENV['US_JOBS_API_KEY']}&kw=java&re=25&rs=1&tm=").
        to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/us.jobs/more_than_25_results.xml"), headers: {})
      stub_request(:get, "http://api2.us.jobs/?key=#{ENV['US_JOBS_API_KEY']}&kw=java&re=25&rs=1").
        to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/us.jobs/more_than_25_results.xml"), headers: {})
      stub_request(:get, "http://api2.us.jobs/?key=#{ENV['US_JOBS_API_KEY']}&kw=java&re=25&rs=1&tm=%20").
        to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/us.jobs/more_than_25_results.xml"), headers: {})
    end

    it "should accept empty and nil parameter values and return with appropriate results page" do
      visit search_jobs_path(kw: "java", tm: "" )
      expect(page).to have_content 'Search the Veterans Job Bank'

      visit search_jobs_path(kw: "java", tm: " " )
      expect(page).to have_content 'Search the Veterans Job Bank'

      visit search_jobs_path(kw: "java", mystery_param: "234")
      expect(page).to have_content 'Search the Veterans Job Bank'

      visit search_jobs_path(kw: "java", nil_param: nil)
      expect(page).to have_content 'Search the Veterans Job Bank'

      visit search_jobs_path(kw: "java", tm: "", mystery_param: "234", nil_param: nil)
      expect(page).to have_content 'Search the Veterans Job Bank'
    end
  end
end
