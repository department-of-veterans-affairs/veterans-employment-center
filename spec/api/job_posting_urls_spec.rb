require 'rails_helper'

describe 'Employer contributed Job Posting URLs API' do
  before do
    user = create(:user, :email => 'veteran1@gmail.com', :password => '12345678')
    create(:employer, :location => 'Cupertino, CA', :website => 'http://www.apple.com', :commit_to_hire => 100, 
           :job_postings_url => 'http://job.postings.url1')
    create(:employer, :company_name => nil, :ein => 234456, :location => 'Anytown, USA', 
           :website => 'www.other.com', :commit_to_hire => 10, :job_postings_url => 'http://job.postings.url2',
           :user => user)
    create(:employer, :company_name => nil, :ein => 234456, :location => 'Anytown, USA', 
           :website => 'www.other.com', :commit_to_hire => 10, :job_postings_url => '',
           :user => user)
    create(:employer, :company_name => 'Yet Another Employer', :ein => 234456, :location => 'Anytown, USA', 
           :website => 'https://www.yetanother.com', :commit_to_hire => 10,
           :user => user)
    create(:employer, :company_name => 'Yet Another Employer', :ein => 234456, :location => 'Anytown, USA', 
           :website => 'https://www.yetanother.com', :commitment_categories => ["Homeless"], :commit_to_hire => 10,
           :user => user)
  end

  context "Request made to JSON API for all current job posting URLs" do
    it "should successfully return JSON containing all job posting URLs" do
      get api_employers_path
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json.size).to eq 2
      expect(json.first["company_name"]).to eq "Apple Computer"
      expect(json.first["url"]).to eq 'http://job.postings.url1'
      expect(json.last["company_name"]).to be_nil
      expect(json.last["url"]).to eq 'http://job.postings.url2'
    end
  end
end

