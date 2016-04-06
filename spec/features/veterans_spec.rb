require 'rails_helper'

feature 'visitors begins to build a new resume' do
  scenario "it does not save a new veteran record when first visiting resume builder" do
    visit new_veteran_path
    expect(Veteran.count).to eq 0
  end

  scenario "a guest user can start a new resume" do
    visit new_veteran_path
    expect(page).to have_content 'build your profile'
    expect(page).not_to have_selector 'h2', text: 'Sign in'
  end
end

feature "an employer visits index of all veterans and can see the veterans" do
  before do
    @user = User.create(email: 'suzy@veteran.org', password: 'Password')
    @vet = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user, visible: true
  end

  scenario "the employer is not logged in" do
    visit veterans_path
    expect(page).to have_content "Only signed in employers or administrators can view this page"
  end

  scenario "a user that is not an employer is logged in" do
    user = create :user, email: 'test@example.com', password: '12345678'
    sign_in_as user
    visit veterans_path
    expect(page).to have_content 'Signed in.'
    expect(page).to have_content "Veterans Employment Center"
    expect(page).not_to have_content "Search for Veterans"
  end

  scenario "the employer is logged in but not approved" do
    non_approved_employer = employer_user
    sign_in_as non_approved_employer
    visit veterans_path
    expect(page).to have_link 'Sign Out'
    expect(page).to have_content 'Search for Veterans'
    expect(page).to have_content 'Candidate'
    expect(page).to have_content @vet.objective
  end

  scenario "the employer is logged in and approved" do
    approved_employer = employer_user
    approved_employer.employer.update_attributes(approved: true)
    sign_in_as approved_employer
    visit veterans_path
    expect(page).to have_link 'Sign Out'
    expect(page).to have_content 'Search for Veterans'
    expect(page).to have_content @vet.name
    expect(page).to have_content @vet.objective
    click_link "Suzy Veteran"
    expect(page).to have_content "Profile"
    expect(page).to have_no_content "Sign in using your DS-LOGON"
  end
end

feature "guests are restricted from editing or viewing veteran data" do
  before do
    @user = User.create(email: 'suzy@veteran.org', password: 'Password')
  end

  scenario "guest cannot view a veteran profile marked as invisible" do
    vet = create :veteran, visible: false, user: @user
    visit veteran_path(vet)
    expect(page).to have_no_selector 'h1', text: 'Résumé'
  end

  scenario "guest cannot view a veteran profile marked as visible" do
    vet = create :veteran, visible: true
    visit veteran_path(vet)
    expect(page).to have_no_selector 'h1', text: 'Résumé'
    expect(page).to have_content "You must be signed in to access this content."
  end

  scenario "guest cannot edit a veteran profile" do
    vet = create :veteran, visible: false, name: "Suzy Veteran"
    visit edit_veteran_path(vet)
    expect(page).to have_content "You must be signed in to access this content."
  end

  scenario "guest can view a resume they created when marked as invisible" do
    visit new_veteran_path
    fill_in_resume_fields
    click_button "Preview Your Veteran Profile and Résumé Content"
    expect(page).to have_selector 'li', text: 'Profile'
  end
end

feature 'employers can view veterans resumes' do
  scenario "a guest user cannot view veteran profiles" do
    vet = create :veteran
    visit veteran_path(vet)
    expect(page).to have_no_selector '.resume_section', text: 'Objective'
    expect(page).to have_content 'Sign in with LinkedIn'
  end

  scenario 'a logged in user that is not an employer cannot view veteran profiles' do
    user = create :user, email: 'test@example.com', password: '12345678'
    login_as user
    vet = create :veteran
    visit veteran_path(vet)
    expect(page).to have_no_selector '.resume_section', text: 'Objective'
    expect(page).to have_selector '#flash_error'
  end

  scenario 'a logged in employer that is not approved can view the profile but not the name' do
    non_approved_employer = employer_user
    sign_in_as non_approved_employer
    vet = create :veteran, name: "Suzy Veteran", objective: "Build great web apps."
    visit veteran_path(vet)
    expect(page).to have_content "Candidate Name/Email Hidden Until You Are Approved"
    expect(page).not_to have_content vet.name
    expect(page).not_to have_selector '#flash_error'
  end

  scenario 'a logged in employer that is approved can view veteran profiles, including names' do
    approved_employer = employer_user
    approved_employer.employer.update_attributes(approved: true)
    sign_in_as approved_employer
    vet = create :veteran, name: "Suzy Veteran", objective: "Build great web apps."
    visit veteran_path(vet)
    expect(page).to have_content vet.name
    expect(page).not_to have_selector 'h2', text: 'Sign in'
  end
end

feature 'a veteran views a resume' do
  scenario 'a logged in veteran can see their own temporary profile' do
    visit new_veteran_path
    fill_in_resume_fields
    click_button "Preview Your Veteran Profile and Résumé Content"
    vet = Veteran.first
    expect(vet.session_id).not_to eq nil
  end

  scenario 'a logged in veteran can edit an existing profile' do
    # edit location for complete test coverage
    stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?address=Mountain%20View,%20CA&language=en&sensor=false").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/location/geocode.json"), headers: {})
    stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?language=en&latlng=37.422918,-122.085421&sensor=false").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/location/geocode.json"), headers: {})
    user = create :user, email: 'suzy@veterans.org', password: '12345678'
    login_as user
    vet = create :veteran, name: "Suzy Veteran", email: 'suzy@veterans.org', objective: "Build great web apps.", user_id: user.id
    visit veteran_path(vet)
    expect(page).to have_content 'Edit Profile'
    click_link 'Edit Profile'
    fill_in "veteran_locations_attributes_0_full_name", with: "Mountain View, CA"
    click_button "Preview Your Veteran Profile and Résumé Content"
    expect(page).to have_content "Mountain View, CA"
  end
end
