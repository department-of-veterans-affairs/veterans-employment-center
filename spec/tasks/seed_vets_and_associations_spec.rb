require 'rails_helper'
require 'rake'

EmploymentPortal::Application.load_tasks

describe "seed tasks" do
  before do
    allow(Geocoder).to receive(:log).and_return(nil)
  end

  describe "veteran seeding task" do
    before do
      stub_request(:get, /http:\/\/maps\.googleapis\.com\/maps\/api\/geocode\/json?.+/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/geocode/location.json"), headers: {})
    end

    it "should seed the DB with ten fictitious veterans" do
      #The rake task db:fictitious_veterans may have already been invoked in another example, so reenable it.
      Rake::Task['db:fictitious_veterans'].reenable
      Rake::Task['db:fictitious_veterans'].invoke(10)
      expect(Veteran.all.size).to eq 10
    end
  end

  describe "affiliation seeding task" do
    before do
      stub_request(:get, /http:\/\/maps\.googleapis\.com\/maps\/api\/geocode\/json?.+/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/geocode/location.json"), headers: {})
    end

    it "should seed the DB with ten fictitious affiliations" do
      #The rake task db:fictitious_veterans may have already been invoked in another example, so reenable it.
      Rake::Task['db:fictitious_veterans'].reenable
      Rake::Task['db:fictitious_veterans'].invoke(10)
      expect(Affiliation.all.size).to eq 0
      Rake::Task['db:fictitious_affiliations'].invoke(10)
      expect(Veteran.all.size).to eq 10
    end
  end

  describe "award seeding task" do
    before do
      stub_request(:get, /http:\/\/maps\.googleapis\.com\/maps\/api\/geocode\/json?.+/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/geocode/location.json"), headers: {})
    end

    it "should seed the DB with ten fictitious awards" do
      #The rake task db:fictitious_veterans may have already been invoked in another example, so reenable it.
      Rake::Task['db:fictitious_veterans'].reenable
      Rake::Task['db:fictitious_veterans'].invoke(10)
      expect(Award.all.size).to eq 0
      Rake::Task['db:fictitious_awards'].invoke(10)
      expect(Veteran.all.size).to eq 10
    end
  end
end
