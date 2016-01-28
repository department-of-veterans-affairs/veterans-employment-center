require 'rails_helper'
require 'rake'

describe Veteran, 'assocations' do
  it "responds to expected values" do
    vet = create :veteran
    expect(vet.session_id).to be_nil
  end
end

describe Veteran, "#work_experiences" do
  it "lists all work experiences, not educational experiences" do
    vet = create :veteran
    experience = create :experience, veteran: vet, experience_type: "employment", organization: "Consulting"
    experience = create :experience, veteran: vet, experience_type: "employment", organization: "Software development"
    experience = create :experience, veteran: vet, experience_type: "education", educational_organization: "Harvard"
    expect(vet.experiences.count).to eq 3
    expect(vet.work_experiences.count).to eq 2
  end
end

describe Veteran, "#educational_experiences" do
  it "lists all educational experiences" do
    vet = create :veteran
    experience = create :experience, veteran: vet, experience_type: "employment", organization: "Consulting"
    experience = create :experience, veteran: vet, experience_type: "employment", organization: "Software development"
    experience = create :experience, veteran: vet, experience_type: "education", educational_organization: "Harvard"
    expect(vet.experiences.count).to eq 3
    expect(vet.educational_experiences.count).to eq 1
  end
end

describe Veteran, "#volunteer_experiences" do
  it "lists all volunteer experiences" do
    vet = create :veteran
    experience = create :experience, veteran: vet, experience_type: "volunteer", organization: "Homeless Shelter"
    experience = create :experience, veteran: vet, experience_type: "employment", organization: "Software development"
    experience = create :experience, veteran: vet, experience_type: "education", educational_organization: "Harvard"
    expect(vet.experiences.count).to eq 3
    expect(vet.volunteer_experiences.count).to eq 1
  end
end

describe Veteran, "#military service" do
  it "lists all military service" do
    vet = create :veteran
    experience = create :experience, veteran: vet, experience_type: "military", organization: "Air Force"
    experience = create :experience, veteran: vet, experience_type: "military", organization: "Coast Guard"
    experience = create :experience, veteran: vet, experience_type: "education", educational_organization: "Harvard"
    expect(vet.experiences.count).to eq 3
    expect(vet.military_experiences.count).to eq 2
  end
end

describe Veteran, "#has_awards" do
  it "returns false if the veteran has an award that is not blank" do
    vet = create :veteran
    award = create :award, veteran: vet
    expect(vet.has_awards?).to eq false
  end

  it "returns true if the veteran has an award that is not blank" do
    vet = create :veteran
    award = create :award, veteran: vet, title: "Blood Letter"
    expect(vet.has_awards?).to eq true
  end
end

describe Veteran, 'purge unassociated veteran records' do
  before do
    Veteran.destroy_all
  end
  
  it "purges from the DB Veteran records older than one day that are not associated with a user" do
    vet_purge_able = create :veteran
    vet_purge_able.update_attributes(updated_at: 3.days.ago)
    expect(Veteran.all.length).to eq 1
    Veteran.purge
    expect(Veteran.all.length).to eq 0
  end

  it "does not purge from the DB any Veteran created within the last day" do
    vet_not_purge_able1 = create :veteran
    vet_not_purge_able1.update_attributes(updated_at: 23.hours.ago)
    expect(Veteran.all.length).to eq 1
    Veteran.purge
    expect(Veteran.all.length).to eq 1
  end

  it "does not purge from the DB any Veteran with a user_id" do
    vet_not_purge_able1 = create :veteran
    vet_not_purge_able1.update_attributes(user_id: 1)
    expect(Veteran.all.length).to eq 1
    Veteran.purge
    expect(Veteran.all.length).to eq 1
  end

  it 'pushes searchable_summary data on save' do
    expect_any_instance_of(Veteran).to receive(:update_column).and_call_original
    FactoryGirl.create(:veteran, objective: 'Get a killer job')
    expect(Veteran.first.searchable_summary).to eq("'get':1 'job':4 'killer':3")
  end

  it 'should batch update searchable_summary' do
    vets = (1..10).map {FactoryGirl.create(:veteran)}
    vets.each{|v| v.update_column :objective, 'get a job'}
    Veteran.update_searchable_summaries
    Veteran.all.each {|v| expect(v.searchable_summary).to match(/job/)}
  end
end
