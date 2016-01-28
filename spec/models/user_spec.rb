require 'rails_helper'

describe User do
	it { should respond_to :email }
  it { should respond_to :password }
  it { should respond_to :employer }
	it { should respond_to :va_admin? }

  it "can have an associated employer" do
    user = create :user
    user.employer = Employer.new(user: user, street_address: "123 Main St", city: "Anywhere", state: "MO", zip: "44444", phone: "222-333-4444")
    user.save
    expect(Employer.first.user).to eq user
  end
end

describe User, '.find_for_google_oauth and .find_for_google_linkedin' do
  it "creates a user in the database unless this email/provider pair already exists" do
    user1 = User.find_for_google_oauth(fake_oauth)
    expect(user1.email).to eq fake_oauth.info.email
    user2 = User.find_for_google_oauth(fake_oauth)
    expect(User.count).to eq 1
    user3 = User.find_for_linkedin_oauth(fake_oauth2)
    expect(user3.email).to eq fake_oauth2.info.email
    expect(User.count).to eq 2
    user4 = User.find_for_linkedin_oauth(fake_oauth2)
    expect(User.count).to eq 2
  end

  it "knows that users that sign in with this method are employers" do
    @user = User.find_for_google_oauth(fake_oauth)
    expect(User.first.is_employer?).to eq true
  end

  it "the new user created by oauth login is associated with an employer" do
    User.find_for_google_oauth(fake_oauth)
    expect(User.first.employer).to be_valid
  end

  it "does not create a second associated employer if the employer logs in again" do
    User.find_for_google_oauth(fake_oauth)
    user = User.first
    user.employer.update_attributes(company_name: "Updated Name")
    user.employer.save
    User.find_for_google_oauth(fake_oauth)
    expect(Employer.count).to eq 1
    expect(user.employer.company_name).to eq "Updated Name"
  end

  def fake_oauth
    mash = Hashie::Mash.new
    mash.uid = "12312312"
    mash.provider = "google_oauth2"
    mash.info!.email = "c.e.worthington@gsa.gov"
    mash
  end

  def fake_oauth2
    mash = Hashie::Mash.new
    mash.uid = "12312312"
    mash.provider = "linkedin"
    mash.info!.email = "c.e.worthington@gsa.gov"
    mash
  end
end
