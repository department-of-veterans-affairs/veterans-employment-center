require 'rails_helper'

feature 'employers edit their accounts' do
  before do
    @user = employer_user
    sign_in_as(@user)
  end    
  
  scenario 'after logging in with google, they can access the edit profile page' do
    visit veterans_path
    click_link "Manage Your Profile and Hiring Commitment"
    expect(page).to have_selector 'h2', text: "Edit your profile"
    fill_in "employer_company_name", with: 'The Editing Company'
    click_button "Update Employer"
    expect(page).to have_selector "#flash_notice",  text: 'The Editing Company was successfully updated.'
  end
 
  scenario 'employers cannot approve themselves' do
    visit edit_employer_path(@user.employer)
    expect(page).to have_no_field "employer_approved"
  end
  
  scenario 'when an employer indicates a hiring commitment category, it appears on their show page' do
    visit edit_employer_path(@user.employer)
    check 'Homeless'
    click_button "Update Employer"
    expect(page).to have_content "Homeless"
  end
  
  scenario 'when an employer indicates a hiring commitment number, it appears on their account and commitments pages' do
    visit edit_employer_path(@user.employer)
    fill_in "employer_commit_to_hire", with: '500'
    click_button "Update Employer"
    visit employer_home_path
    expect(page).to have_content "publicly committed to hire 500 Veterans."
    expect(page).to have_no_content "publicly committed to hire 500 Veterans by"
    expect(page).to have_no_content "You haven't yet made a public commitment to hire Veterans"
    visit commitments_path
    expect(page).to have_content "publicly committed to hire 500 Veterans."
    expect(page).to have_no_content "publicly committed to hire 500 Veterans by"
    expect(page).to have_no_content "You haven't yet made a public commitment to hire Veterans"
  end
  
  scenario 'when an employer indicates a hiring commitment number AND date, both appear on their account and commitments pages' do
    visit edit_employer_path(@user.employer)
    fill_in "employer_commit_to_hire", with: '500'
    fill_in "employer_commit_date", with: '05/15/2016'
    click_button "Update Employer"
    visit employer_home_path
    expect(page).to have_content "publicly committed to hire 500 Veterans by May 15, 2016"
    expect(page).to have_no_content "You haven't yet made a public commitment to hire Veterans"
    visit commitments_path
    expect(page).to have_content "publicly committed to hire 500 Veterans by May 15, 2016"
    expect(page).to have_no_content "You haven't yet made a public commitment to hire Veterans"
  end
  
  scenario 'when an employer removes their hiring commitment number, it no longer appears on their account and commitments pages' do
    visit edit_employer_path(@user.employer)
    fill_in "employer_commit_to_hire", with: '500'
    click_button "Update Employer"
    visit employer_home_path
    expect(page).to have_content "publicly committed to hire 500 Veterans."
    visit commitments_path
    expect(page).to have_content "publicly committed to hire 500 Veterans."
    visit edit_employer_path(@user.employer)
    fill_in "employer_commit_to_hire", with: ''
    click_button "Update Employer"
    visit employer_home_path
    expect(page).to have_content "You haven't yet made a public commitment to hire Veterans"
    visit commitments_path
    expect(page).to have_content "You haven't yet made a public commitment to hire Veterans"
  end
  
  scenario 'an employer can specify a job posting url' do
    visit edit_employer_path(@user.employer)
    fill_in "Employer Name", with: 'Example Inc.'
    fill_in 'URL of page with job postings', with: "http://example.com/jobs"
    click_button "Update Employer"
    expect(page).to have_content "Example Inc. was successfully updated"
  end

  scenario 'one employer cannot edit another employers profile' do
    other_employer = create :employer
    visit edit_employer_path(other_employer)
    expect(page).to have_no_content 'Edit your profile'
    expect(page).to have_selector "#flash_warn", text: 'You are not authorized to edit this profile.'
  end
  
  scenario 'when an employer views their account information, they do not see admin notes' do
    visit employer_path(@user.employer)
    expect(page).to have_no_content("Admin notes")   
  end
  
  scenario 'when an employer edits their account information, they do not see admin notes' do
    visit edit_employer_path(@user.employer)
    expect(page).to have_no_content("Admin notes")   
  end
  
  scenario 'when an employer views their account information, the back button does not show up' do
    visit employer_path(@user.employer)
    expect(page).to have_no_link("Back")    
  end
  
  scenario 'when an employer edits their account information, the back button does not show up' do
    visit edit_employer_path(@user.employer)
    expect(page).to have_no_link("Back")    
  end  
end

feature 'employers can search veteran profiles' do
  before do
    user = employer_user
    sign_in_as(user)
  end
  
  scenario 'employers click on search veterans link and they arrive at the veterans index page' do
    visit veterans_path
    expect(page).to have_content "Search for Veterans"
  end
end

feature 'only admins can access employer index' do
  scenario "non-logged in user visits employer index route" do
    visit employer_list_path
    expect(page).to have_content "You need to sign in or sign up before continuing"
  end

  scenario "logged in user visits employer index, but they are not an admin" do
    non_admin_user = create :user, email: 'test@example.com', password: '12345678'
    sign_in_as non_admin_user
    visit employer_list_path
    expect(page).to have_content "unauthorized access"
  end

  scenario "logged in admin user visits employer index, and they see the employers" do
    sign_in_as_admin
    visit employer_list_path
    expect(page).to have_content "Listing Employers"
  end
end

feature "logged in admin can search for employers on employer index page" do
  before do
    user1 = create :user, email: "email1@example.com", password: '123456'
    user2 = create :user, email: "email2@example.com", password: '234567'
    employer1 = create :employer, company_name: "Dell Computer", ein: "12345678", approved: false, user_id: user1.id, poc_name: "Delia D.", poc_email: "poc@dell.com", location: "DTown, USA"
    employer2 = create :employer, company_name: "Apple Computer", ein: "23452245", approved: true, user_id: user2.id, poc_name: "Appelonia A.", poc_email: "poc@apple.com", location: "Aville, USA"
    sign_in_as_admin
    visit '/employer-list'
  end
    
  scenario "with no search query terms, all employers are listed" do
    expect(page).to have_content "Dell Computer"
    expect(page).to have_content "Apple Computer"
  end

  scenario "admin can search employers by company_name" do
    fill_in "keywords", with: 'dell'
    click_button("employer-search")
    expect(page).to have_content "Dell Computer"
    expect(page).to_not have_content "Apple Computer"
  end

  scenario "admin can search employers by ein" do
    fill_in "keywords", with: '123'
    click_button("employer-search")
    expect(page).to have_content "Dell Computer"
    expect(page).to_not have_content "Apple Computer"
  end

  scenario "admin can search employers by user.email" do
    fill_in "keywords", with: 'email1'
    click_button("employer-search")
    expect(page).to have_content "Dell Computer"
    expect(page).to_not have_content "Apple Computer"
  end

  scenario "admin can search employers by poc_email" do
    fill_in "keywords", with: '@dell.com'
    click_button("employer-search")
    expect(page).to have_content "Dell Computer"
    expect(page).to_not have_content "Apple Computer"
  end

  scenario "admin can search employers by poc_name" do
    fill_in "keywords", with: 'delia'
    click_button("employer-search")
    expect(page).to have_content "Dell Computer"
    expect(page).to_not have_content "Apple Computer"
  end

  scenario "admin can search employers by location" do
    fill_in "keywords", with: 'dtown'
    click_button("employer-search")
    expect(page).to have_content "Dell Computer"
    expect(page).to_not have_content "Apple Computer"
  end
end 


feature 'admins can edit an employer' do
  scenario 'they can visit the edit employer page' do
    employer = create :employer
    sign_in_as_admin
    visit edit_employer_path(employer)
    expect(page).to have_content "Edit the Profile for #{employer.company_name}"
  end

  scenario 'they can make an admin note' do
    employer = create :employer
    sign_in_as_admin
    visit edit_employer_path(employer)
    fill_in "employer_admin_notes", with: 'Called and left messag'
    click_button "Update Employer"
    expect(page).to have_selector "#flash_notice",  text: 'was successfully updated.'
  end
end

feature 'admins can approve an employer', js: true, driver: :webkit do
  scenario 'admin sees all employers on index page' do
    employer = create :employer, company_name: "Apple Computer", ein: "12345211"
    sign_in_as_admin
    visit employer_list_path
    expect(page).to have_selector('.employer_name', text: "Apple Computer")
  end

  scenario 'approved employers are noted as approved' do
    create :employer, company_name: "Apple Computer", ein: "12345211", approved: true
    sign_in_as_admin
    visit employer_list_path
    expect(page).to have_selector('.approval_status', text: 'Approved')
  end

  scenario 'unapproved employers are noted as not approved, with a link to approve them' do
    create :employer, company_name: "Dell Computer", ein: "12345211", approved: false
    sign_in_as_admin
    visit employer_list_path
    expect(page).to have_selector('.approval_status', text: 'Unapproved')
    expect(page).to have_link('Approve')
  end

  scenario 'admin can click "approve" button to mark an employer as approved' do
    employer = create :employer, company_name: "Apple Computer", ein: "12345211"
    sign_in_as_admin
    visit employer_list_path
    click_link "Approve"
    expect(page).to have_selector('#flash_notice', text: "#{employer.company_name} was successfully updated.")
    expect(page).to have_selector('.approval_status',  "Approved")
  end

  scenario 'after an admin approves an employer, the admin email and the date appear on employer index' do
    employer = create :employer, company_name: "Apple Computer", ein: "12345211"
    sign_in_as_admin
    visit employer_list_path
    click_link "Approve"
    # How can I make this reflect the current admin user email? I tried admin_user and current_user.
    expect(page).to have_content "Approved by test@va.gov on #{Time.current.to_date}"
  end

end

feature 'admins can see employer emails' do
  scenario 'they can visit the employee index page' do
    employer = create :employer, company_name: "Apple Computer", ein: "12345211"
    sign_in_as_admin
    visit employer_list_path
    expect(page).to have_content "test@example.com"
  end
end

feature 'logging out' do
  scenario 'when logged in, an employer can log out' do
    sign_in_as(employer_user)
    visit employer_list_path
    click_link 'Sign Out'
    expect(page).to have_content 'Job Seekers'
  end
end
