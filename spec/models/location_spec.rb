require 'rails_helper'

describe Location, 'full_name' do
  before do
    allow(Geocoder).to receive(:log).and_return(nil)
  end

  describe "geocoding a given location" do
    context "when a valid location is provided as city and state" do
      it "does not geocode the location, therefore does not find lat, lng, and zip" do
        loc = Location.create!(city: "Mountain View", state: "CA")
        expect(loc.lat).to be_nil
        expect(loc.lng).to be_nil
        expect(loc.city).to eq "Mountain View"
        expect(loc.state).to eq "CA"
        expect(loc.zip).to be_nil
      end
    end

    context "when a valid location is provided as full_name" do
      before do
        stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?address=Mountain%20View,%20CA&language=en&sensor=false").
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/location/geocode.json"), headers: {})
        stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?language=en&latlng=37.422918,-122.085421&sensor=false").
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/location/geocode.json"), headers: {})
      end

      it "after validation it geocodes the location and reverse geocodes it to get lat, lng, and zip" do
        loc = Location.create!(full_name: "Mountain View, CA")
        expect(loc.lat).to eq 37.422918
        expect(loc.lng).to eq -122.085421
        expect(loc.city).to eq "Mountain View"
        expect(loc.state).to eq "California"
        expect(loc.zip).to eq "94043"
      end
    end
  end
end
