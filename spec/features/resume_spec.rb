require 'rails_helper'

## Used for the autocompletion spec
  def fill_autocomplete(field, options = {})
    fill_in field, with: options[:with]
    page.execute_script %Q{ $('##{field}').trigger('focus') }
    page.execute_script %Q{ $('##{field}').trigger('keydown') }
    selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{options[:select]}")}
    page.should have_selector('ul.ui-autocomplete li.ui-menu-item a')
    page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
  end

feature "guest can create a new resume for themselves" do
  scenario 'guest fills in all the fields of the resume' do
    visit new_veteran_path
    fill_in_resume_fields
    click_button "Preview Your Résumé Content"
    expect(page).to have_content("Edit Résumé")
  end

  scenario 'it saves a session to the veteran' do
    visit new_veteran_path
    fill_in_resume_fields
    click_button "Preview Your Résumé Content"
    vet = Veteran.first
    expect(vet.session_id).not_to eq nil
  end
end

feature 'when building a resume, the resume only shows the fields that it should' do

  scenario 'a vet submits a resume with only a name and email' do
    visit resume_builder_path
    fill_in 'Your full name', with: 'Suzy Veteran'
    fill_in 'Your email', with: 'suzy@veterans.org'
    click_button 'Preview Your Résumé Content'
    within('#resume') do
      expect(page).not_to have_content 'Objective'
      expect(page).not_to have_content 'Awards'
      expect(page).not_to have_content 'Work Experience'
      expect(page).not_to have_content 'Education'
      expect(page).not_to have_content 'Volunteer Experience'
      expect(page).not_to have_content 'Military Service'
      expect(page).not_to have_content 'Professional Affiliations'
      expect(page).not_to have_content 'References'
      expect(page).not_to have_content "Special Status"
      expect(page).not_to have_content "Accelerated Learning Programs"
      expect(page).to have_content "Suzy Veteran"
      expect(page).to have_content "Profile Last Updated: #{Date.current.strftime("%B %d, %Y")}"
    end
  end

  scenario 'a vet fills in a partial location then selects choice given by autocompletion', js: true, driver: :webkit do
    pending "Solution to rack application time out"
    #TODO: Solve Rack application timed out during boot due to the following code
      # The stub_request step below causes a timeout error, slowing down this pending test.
      # In turn it slows the entire test suite significantly. The "expect(true).to eq(false)"
      # statement forces an error,thereby allowing this pending test to pass (as pending)
      # before the stub_request has a chance to slow things down.

      # REMOVE THE FOLLOWING STATEMENT ONCE A SOLUTION TO THE TIMEOUT PROBLEM IS FOUND
      expect(true).to eq(false)
      #####

      stub_request(:get, /http:\/\/127\.0\.0\.1.*\/__identify__/).with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/auto_location.txt"), headers: {})
      visit resume_builder_path
      fill_in 'Your full name', with: 'Suzy Veteran'
      fill_in 'Your email', with: 'suzy@veterans.org'
      fill_autocomplete "veteran_locations_attributes_0_full_name", with: "Phil", select: "Philadelphia PA, United States"
      click_button 'Preview Your Résumé Content'
      expect(page).to have_content "Philadelphia, PA, United States"
  end

  scenario 'a vet fills in a resume' do
    visit resume_builder_path
    fill_in 'Your full name', with: 'Suzy Veteran'
    fill_in 'Your email', with: 'suzy@veterans.org'
    fill_in 'veteran_objective', with: 'An amazing objective'
    fill_in 'veteran_availability_date', with: '02/07/2015'
    fill_in 'Name of award', with: 'An amazing award'
    fill_in 'Awarding organization', with: 'Awarders'
    select 'E-2', from: 'veteran_experiences_attributes_1_rank'
    fill_in 'veteran_experiences_attributes_1_job_title', with: 'Captain'
    fill_in 'veteran_experiences_attributes_1_organization', with: 'Navy'
    fill_in 'veteran_experiences_attributes_2_job_title', with: 'Captain of Industry'
    fill_in 'veteran_experiences_attributes_2_organization', with: 'Naval Industries'
    fill_in 'veteran_experiences_attributes_2_hours', with: '55'
    fill_in 'Name of school or training', with: 'Harvard'
    fill_in 'veteran_experiences_attributes_3_job_title', with: "Homeless Shelter"
    fill_in 'veteran_experiences_attributes_3_organization', with: 'Helping homeless'
    fill_in 'Affiliation', with: 'Head Mason'
    fill_in 'Affiliated organization', with: 'Masons'
    fill_in 'veteran_references_attributes_0_name', with: 'John Doe'
    click_button 'Preview Your Résumé Content'
    expect(page).to have_content 'Objective'
    expect(page).to have_content 'An amazing objective'
    expect(page).to have_content 'February 07, 2015'
    expect(page).to have_content 'Awards'
    expect(page).to have_content 'An amazing award'
    expect(page).to have_content 'Work Experience'
    expect(page).to have_content 'E2'
    expect(page).to have_content 'Captain'
    expect(page).to have_content 'Education'
    expect(page).to have_content 'hours/week'
    expect(page).to have_content '55'
    expect(page).to have_content 'Harvard'
    expect(page).to have_content 'Military Service'
    expect(page).to have_content 'Volunteer Experience'
    expect(page).to have_content 'Helping homeless'
    expect(page).to have_content 'Professional Affiliations'
    expect(page).to have_content 'Head Mason'
    expect(page).to have_content 'Masons'
    expect(page).to have_content 'References'
    expect(page).to have_content 'John Doe'
    click_link 'Edit Résumé'
    expect(page).to have_content 'An amazing objective'
    expect(find_field('veteran_availability_date').value).to eq '02/07/2015'
    expect(find_field('Name of award').value).to eq 'An amazing award'
    expect(find_field('veteran_experiences_attributes_1_rank').value).to eq 'E2'
    expect(find_field('veteran_experiences_attributes_1_job_title').value).to eq 'Captain'
    expect(find_field('veteran_experiences_attributes_2_job_title').value).to eq 'Captain of Industry'
    expect(find_field('Name of school or training').value).to eq 'Harvard'
    expect(find_field('veteran_experiences_attributes_3_job_title').value).to eq 'Homeless Shelter'
    expect(find_field('veteran_experiences_attributes_3_organization').value).to eq 'Helping homeless'
    expect(find_field('Affiliation').value).to eq 'Head Mason'
    expect(find_field('Affiliated organization').value).to have_content 'Masons'
    expect(find_field('veteran_references_attributes_0_name').value).to have_content 'John Doe'
  end

  # scenario 'a vet creates a federal resume' do
  #   visit resume_builder_path
  #   page.find("#fed_resume_show").click
  #   fill_in 'Your Name', :with => 'Suzy Veteran'
  #   fill_in 'Your Email', :with => 'suzy@veterans.org'
  #   fill_in 'veteran_objective', :with => 'An amazing objective'
  #   fill_in 'Ex: Announcement 339-10-42, Employment Coordinator, GS-0301', :with => '100, Mechanic, gs100'
  #   fill_in 'Country of citizenship', :with => "US"
  #   fill_in 'Mailing Address', :with => "1234 Penny Lane, Washington, DC 20016"
  #   fill_in 'Day Phone Number', :with => "1-234-456-7890"
  #   fill_in 'Evening Phone Number', :with => "2-234-456-7890"
  #   fill_in 'Ex: 10 points, leave blank if none.', :with => "20 points"
  #   fill_in 'Highest Federal Civilian Grade Held', :with => 'gs8'
  #   fill_in 'Reinstatement Eligibility', :with => 'none'

  #   click_button 'Preview Your Résumé Content'
  #   expect(page).to have_content 'Objective'
  #   expect(page).to have_content 'An amazing objective'
  #   expect(page).to have_content 'Citizenship: US'
  #   expect(page).to have_content 'Mailing Address'
  #   expect(page).to have_content '1234 Penny Lane, Washington, DC 20016'
  #   expect(page).to have_content 'Daytime Phone Number'
  #   expect(page).to have_content '1-234-456-7890'
  #   expect(page).to have_content 'Evening Phone Number'
  #   expect(page).to have_content "2-234-456-7890"
  #   expect(page).to have_content 'Veterans Preference'
  #   expect(page).to have_content "20 points"
  #   expect(page).to have_content 'Job Announcement Number, Job Title and Job Grade'
  #   expect(page).to have_content '100, Mechanic, gs100'
  #   expect(page).to have_content 'Reinstatement Eligibility'
  #   expect(page).to have_content 'none'
  #   expect(page).to have_content 'Highest Federal Civilian Grade Held'
  #   expect(page).to have_content 'gs8'
  # end

#  scenario "you can delete fields on create page",:js => true,driver: :webkit  do
#    visit resume_builder_path
#    fill_in 'Your Name', with: 'Suzy Veteran'
#    fill_in 'Your Email', with: 'suzy@veterans.org'
#    fill_in 'veteran_objective', with: 'An amazing objective'
#    fill_in 'Name of school or training', with: 'Harvard'
##################################################################
# The below javascript doesn't throw an error, but it also doesn't
# modify the page's html to remove the Education section. Part of
# the issue is that it's using a 'span' element rather than a
# button or link. The other is that it's trying to modify the page
# which is currently very difficult to do in testing
##################################################################
#    page.execute_script %Q($('.experience-deleter').first().click())
#    click_button 'Preview Your Résumé Content'
#    expect(page).to have_content "Suzy Veteran"
#    expect(page).to have_content 'Objective'
#    expect(page).to have_content 'An amazing objective'
#    expect(page).not_to have_content 'Education'
#    expect(page).not_to have_content 'Harvard'
#  end

  scenario "autofilling your resume with LinkedIn" do
    stub_request(:get, "https://api.linkedin.com/v1/people/~:(email-address,first-name,last-name,location,positions,educations,skills,volunteer,honors-awards,recommendations-received)").
      to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/json/linkedin_profile.json"), headers: {})
    visit resume_builder_path
    click_link 'Auto-fill from LinkedIn'
    expect(page).to have_no_link 'Auto-fill résumé from your LinkedIn profile'
    expect(page).to have_content 'Your resume has been prefilled with your LinkedIn information.'
    expect(find_field('Your full name').value).to eq 'Joe Veteran'
    expect(find_field('Your email').value).to eq 'joe@veteran.com'

    expected_skills = ['Ruby on Rails', 'Lucene', 'MySQL']
    page.assert_selector('#checkbox-list > li', count: expected_skills.length)
    expected_skills.each do |name|
      expect(page).to have_selector('#checkbox-list > li > span', text: name)
    end

    expect(find_field('veteran_experiences_attributes_0_educational_organization').value).to eq 'Undergraduate University'
    expect(find_field('veteran_experiences_attributes_0_credential_type').value).to eq "Bachelor's Degree"
    expect(find_field('veteran_experiences_attributes_0_credential_topic').value).to eq 'Computer Science'
    expect(find_field('veteran_experiences_attributes_0_start_date').value).to eq '01/01/1995'
    expect(find_field('veteran_experiences_attributes_0_end_date').value).to eq '01/01/1999'
    expect(find_field('veteran_experiences_attributes_1_educational_organization').value).to eq 'Graduate University'
    expect(find_field('veteran_experiences_attributes_1_credential_type').value).to eq "Master's Degree"
    expect(find_field('veteran_experiences_attributes_1_credential_topic').value).to eq 'Computer Science'

    expect(find_field('veteran_experiences_attributes_3_job_title').value).to eq "Software developer"
    expect(find_field('veteran_experiences_attributes_3_organization').value).to eq "Current Software Company"
    expect(find_field('veteran_experiences_attributes_3_description').value).to eq "Beginning software developer"
    expect(find_field('veteran_experiences_attributes_3_start_date').value).to eq "02/01/2014"
    expect(find_field('veteran_experiences_attributes_3_end_date').value).to be_nil

    expect(find_field('veteran_experiences_attributes_4_job_title').value).to eq "Senior Software Developer"
    expect(find_field('veteran_experiences_attributes_4_organization').value).to eq "ACME Inc."
    expect(find_field('veteran_experiences_attributes_4_description').value).to eq "Working as a software developer."
    expect(find_field('veteran_experiences_attributes_4_start_date').value).to eq "01/01/2013"
    expect(find_field('veteran_experiences_attributes_4_end_date').value).to eq "01/01/2014"


    expect(find_field('veteran_experiences_attributes_5_job_title').value).to eq "Software developer"
    expect(find_field('veteran_experiences_attributes_5_organization').value).to eq "Another Software Company"
    expect(find_field('veteran_experiences_attributes_5_description').value).to eq "Beginning software developer"
    expect(find_field('veteran_experiences_attributes_5_start_date').value).to eq "02/01/2013"
    expect(find_field('veteran_experiences_attributes_5_end_date').value).to eq "10/01/2013"

    expect(find_field('veteran_experiences_attributes_6_job_title').value).to eq "Junk Sortable Entry"

    expect(find_field('veteran_experiences_attributes_7_job_title').value).to eq "Volunteer"
    expect(find_field('veteran_experiences_attributes_7_organization').value).to eq "Pretend Volunteer Organization"
    expect(find_field('veteran_awards_attributes_0_title').value).to eq "Pretend Award"
    expect(find_field('veteran_awards_attributes_0_organization').value).to eq "Pretend Awarder"
    expect(find_field('veteran_locations_attributes_0_full_name').value).to eq "Washington D.C. Metro Area"
  end

  # scenario "autofilling your resume with LinkedIn AND adding federal resume fields" do
  #   stub_request(:get, "https://api.linkedin.com/v1/people/~:(email-address,first-name,last-name,location,positions,educations,skills,volunteer,honors-awards,recommendations-received)").
  #     to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/json/linkedin_profile.json"), :headers => {})
  #   visit resume_builder_path
  #   page.find("#fed_resume_show").click
  #   fill_in 'Ex: Announcement 339-10-42, Employment Coordinator, GS-0301', :with => '100, Mechanic, gs100'
  #   fill_in 'Country of citizenship', :with => "US"
  #   fill_in 'Mailing Address', :with => "1234 Penny Lane, Washington, DC 20016"
  #   fill_in 'Day Phone Number', :with => "1-234-456-7890"
  #   fill_in 'Evening Phone Number', :with => "2-234-456-7890"
  #   fill_in 'Ex: 10 points, leave blank if none.', :with => "20 points"
  #   fill_in 'Highest Federal Civilian Grade Held', :with => 'gs8'
  #   fill_in 'Reinstatement Eligibility', :with => 'none'

  #   click_link 'Auto-fill résumé from your LinkedIn profile'
  #   visit resume_builder_path
  #   expect(page).to have_no_link 'Auto-fill resume from your LinkedIn profile'
  #   expect(page).to have_content 'Your resume has been prefilled with your LinkedIn information.'
  #   expect(find_field('Your Name').value).to eq 'Joe Veteran'
  #   expect(find_field('Your Email').value).to eq 'joe@veteran.com'
  #   expect(find_field('veteran_skills_ruby_on_rails')).to be_checked
  #   expect(find_field('veteran_skills_lucene')).to be_checked
  #   expect(find_field('veteran_skills_mysql')).to be_checked
  #   expect(find_field('veteran_experiences_attributes_0_educational_organization').value).to eq 'Undergraduate University'
  #   expect(find_field('veteran_experiences_attributes_0_credential_type').value).to eq "Bachelor's Degree"
  #   expect(find_field('veteran_experiences_attributes_0_credential_topic').value).to eq 'Computer Science'
  #   expect(find_field('veteran_experiences_attributes_0_start_date').value).to eq '01/01/1995'
  #   expect(find_field('veteran_experiences_attributes_0_end_date').value).to eq '01/01/1999'
  #   expect(find_field('veteran_experiences_attributes_1_educational_organization').value).to eq 'Graduate University'
  #   expect(find_field('veteran_experiences_attributes_1_credential_type').value).to eq "Master's Degree"
  #   expect(find_field('veteran_experiences_attributes_1_credential_topic').value).to eq 'Computer Science'
  #   expect(find_field('veteran_experiences_attributes_3_job_title').value).to eq "Senior Software Developer"
  #   expect(find_field('veteran_experiences_attributes_3_organization').value).to eq "ACME Inc."
  #   expect(find_field('veteran_experiences_attributes_3_description').value).to eq "Working as a software developer."
  #   expect(find_field('veteran_experiences_attributes_3_start_date').value).to eq "01/01/2013"
  #   expect(find_field('veteran_experiences_attributes_3_end_date').value).to eq "01/01/2014"
  #   expect(find_field('veteran_experiences_attributes_4_job_title').value).to eq "Software developer"
  #   expect(find_field('veteran_experiences_attributes_4_organization').value).to eq "Another Software Company"
  #   expect(find_field('veteran_experiences_attributes_4_description').value).to eq "Beginning software developer"
  #   expect(find_field('veteran_experiences_attributes_4_start_date').value).to eq "02/01/2013"
  #   expect(find_field('veteran_experiences_attributes_4_end_date').value).to eq "10/01/2013"
  #   expect(find_field('veteran_experiences_attributes_5_job_title').value).to eq "Volunteer"
  #   expect(find_field('veteran_experiences_attributes_5_organization').value).to eq "Pretend Volunteer Organization"
  #   expect(find_field('veteran_awards_attributes_0_title').value).to eq "Pretend Award"
  #   expect(find_field('veteran_awards_attributes_0_organization').value).to eq "Pretend Awarder"
  #   expect(find_field('veteran_locations_attributes_0_full_name').value).to eq "Washington D.C. Metro Area"
  # end

  scenario "autofilling your resume with a minimal profile" do
    stub_request(:get, "https://api.linkedin.com/v1/people/~:(email-address,first-name,last-name,location,positions,educations,skills,volunteer,honors-awards,recommendations-received)").
      to_return(status: 200, body: File.read(Rails.root.to_s + "/spec/support/json/linkedin_basic_profile.json"), headers: {})
    visit resume_builder_path
    click_link 'Auto-fill from LinkedIn'
    visit resume_builder_path
    expect(find_field('Your full name').value).to eq 'Joe Veteran'
    expect(find_field('Your email').value).to eq 'joe@veteran.com'
    expect(find_field('veteran_locations_attributes_0_full_name').value).to eq "Washington D.C. Metro Area"
  end
end

feature "profile creation shouldn't redirect to employer login", js: true do
  before do
    @user = employer_user
    sign_in_as(@user)
  end

  scenario "sign in and out as employer before creating a resume as a vet" do
    visit employers_path
    click_link 'Sign Out'

    visit new_veteran_path
    fill_in 'Your full name', with: 'Suzy Veteran'
    fill_in 'Your email', with: 'suzy@veterans.org'
    click_button 'Preview Your Résumé Content'
    expect(page).to have_content("Edit Résumé")
  end
end

feature "you can view and edit a profile after creation" do

  scenario "create and edit profile with no fields filled out" do
    visit new_veteran_path
    fill_in 'Your full name', with: 'Suzy Veteran'
    fill_in 'Your email', with: 'suzy@veterans.org'
    fill_in 'veteran_objective', with: 'An amazing objective'
    click_button 'Preview Your Résumé Content'
    click_link "Edit Résumé"
    expect(page).to have_content "Add the Basics"
    expect(page).to have_content "An amazing objective"
  end

  #scenario "you can delete fields on edit"
  #end
end
