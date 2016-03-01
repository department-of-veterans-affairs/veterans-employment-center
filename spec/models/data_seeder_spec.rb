require 'rails_helper'
require 'rake'

describe 'Data Seeding' do

  context "before seeding the DB" do
    it "should have no data in relevant DB table" do
      expect MilitaryOccupation.all.empty?
    end
  end

  context "after seeding the DB" do
    before do
      load Rails.root + "db/seeds.rb"
    end

    it "should seed the military_occupations table" do
      expect MilitaryOccupation.all.size > 0
    end
  end
end
