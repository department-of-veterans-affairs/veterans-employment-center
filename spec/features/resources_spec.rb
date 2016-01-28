require 'rails_helper'

feature 'users can access the resources page' do
  before do
    visit for_job_seekers_path
    click_link 'Resources'
  end

  scenario 'the page has the right title' do
    expect(page).to have_css '.active', text: 'Job Resources'
  end

  resource_pages = ['Disability Resources', 'Assistive Technology', 'Education & Counseling', 'Military Transcripts', 'Federal Employment', 'Military Spouses', 'Partnered Resources', 'Small Business & Entrepreneurship', 'Training & Vocational', 'Transitioning Servicemembers', 'Wounded Warrior']

  resource_pages.each do |resource|
    scenario "there are resources for #{resource}" do
      click_link resource
      expect(page).to have_css '.active', text: resource
    end
  end
end