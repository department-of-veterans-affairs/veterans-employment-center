
require 'rails_helper'

feature 'visitors begins to build a new resume' do
  scenario "it does not save a new veteran record when first visiting resume builder" do
    visit new_veteran_path
    expect(Veteran.count).to eq 0
  end

  scenario "a guest user can start a new resume" do
    visit new_veteran_path
    expect(page).to have_content 'enter your information'
    expect(page).to have_no_selector 'h2', text: 'Sign in'
  end
end

feature 'employers can view veterans resumes' do

  scenario "a guest user cannot view veteran profiles" do
    vet = create :veteran
    visit veteran_path(vet)
    expect(page).to have_content 'You do not have access to that content'
  end

  scenario 'a logged in user that is not an employer cannot view veteran profiles' do
    user = create :user, email: 'test@example.com', password: '12345678'
    sign_in_as user
    vet = create :veteran
    visit veteran_path(vet)
    expect(page).to have_content "You do not have access to that content"
  end

  scenario 'a logged in employer that is not approved cannot view the profile' do
    non_approved_employer = employer_user
    sign_in_as non_approved_employer
    vet = create :veteran, name: "Suzy Veteran", objective: "Build great web apps."
    visit veteran_path(vet)
    expect(page).to have_content "You do not have access to that content"
  end

  scenario 'a logged in employer that is approved cannot view veteran profiles' do
    approved_employer = employer_user
    approved_employer.employer.update_attributes(approved: true)
    sign_in_as approved_employer
    vet = create :veteran, name: "Suzy Veteran", objective: "Build great web apps."
    visit veteran_path(vet)
    expect(page).to have_content 'You do not have access to that content'
  end

  scenario 'a logged in employer that is not approved cannot download the resume' do
    non_approved_employer = employer_user
    sign_in_as non_approved_employer
    vet = create :veteran, name: "Suzy Veteran", objective: "Build great web apps."
    visit veteran_path(vet)
    expect(page).to have_content 'You do not have access to that content'
  end

  scenario 'a logged in employer that is approved cannot download the resume' do
    approved_employer = employer_user
    approved_employer.employer.update_attributes(approved: true)
    sign_in_as approved_employer
    vet = create :veteran, name: "Suzy Veteran", objective: "Build great web apps."
    visit veteran_path(vet)
    expect(page).to have_content 'You do not have access to that content'
  end

  scenario 'a logged in employer that is approved cannot download the resumes' do
    approved_employer = employer_user
    approved_employer.employer.update_attributes(approved: true)
    sign_in_as approved_employer
    vet = create :veteran, name: "Suzy Veteran", objective: "Build great web apps."
    military_experience = create :military_experience
    vet.experiences <<  military_experience
    visit veteran_path(vet)
    expect(page).to have_content 'You do not have access to that content'
  end

end
