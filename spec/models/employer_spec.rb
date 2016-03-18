require 'rails_helper'

describe Employer do
  it { should respond_to :user }

  it "should not be created without a user" do
    employer = Employer.new
    expect(employer).to be_invalid
  end

  it "should validate EIN" do
    employer = create(:employer)
    expect(employer).to be_valid

    invalid = ["alpha", "1234-5789", -12, 123456789012345678901, "23423423423423ff"]
    invalid.each do |ex|
      employer.ein = ex
      expect(employer).to be_invalid
    end

    valid = ['', "123456789", 234235289]
    valid.each do |ex|
      employer.ein = ex
      expect(employer).to be_valid
    end
  end

  it "should validate commit_to_hire" do
    employer = create(:employer)
    expect(employer).to be_valid

    invalid = [0, "alpha", -12, 11111111]
    invalid.each do |ex|
      employer.commit_to_hire = ex
      expect(employer).to be_invalid
    end

    valid = [1, "123", 2342352]
    valid.each do |ex|
      employer.commit_to_hire = ex
      expect(employer).to be_valid
    end
  end
  
  it "should validate commit_hired" do
    employer = create(:employer)
    expect(employer).to be_valid

    invalid = ["alpha", -12, 11111111]
    invalid.each do |ex|
      employer.commit_hired = ex
      expect(employer).to be_invalid
    end

    valid = [0, "123", 2342352]
    valid.each do |ex|
      employer.commit_hired = ex
      expect(employer).to be_valid
    end
  end
end
