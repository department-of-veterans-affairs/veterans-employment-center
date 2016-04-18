require 'rails_helper'
#include 'render_csv'

describe "Employers" do
  describe "GET /employer-list" do
    it "should not load for an anonymous visitor" do
      get employer_list_path
      expect(response.status).to eq 302
    end

    pending "should not load for an employer user"
    pending "should not load for a veteran user"
    pending "should load for an admin user"
  end

  describe "GET /employers" do
    it "should NOT show Your Employer Account breadcrumb if the user is not signed in" do
      visit employer_home_path
      expect(page).to have_content 'Log in to create and manage your account'
      expect(page).to have_content 'LinkedIn'
      expect(page).to have_selector 'li', text: 'Employers'
    end

    it "should NOT show Your Employer Account breadcrumb if logged-in Veteran" do
      veteran = create :user, email: 'test@example.com', password: '12345678'
      sign_in_as veteran
      visit employer_home_path
      expect(page).to have_selector 'li', text: 'Employers'
      expect(page).not_to have_selector 'li', text: 'Your Employer Account'
    end

    it "should show Your Employer Account breadcrumb if logged-in employer" do
      employer = employer_user
      sign_in_as employer
      visit employer_home_path
      expect(page).to have_content 'Sign Out'
      expect(page).to have_selector 'li', text: 'Your Employer Account'
    end

    it "should prompt user to log in if they aren't yet signed in" do
      visit employer_home_path
      click_link 'View All Hiring Commitments'
      expect(page).to have_link 'Sign in with LinkedIn'
    end

    it "should redirect to edit profile page if logged-in employer clicks Make a Hiring Commitment in Employer sidebar" do
      employer = employer_user
      sign_in_as employer
      visit employer_home_path
      click_link 'Manage Your Profile and Hiring Commitment'
      expect(page).to have_content 'Edit your profile'
      expect(page).to have_content 'Sign Out'
    end
  end

  describe "GET /commitments" do
    before do
      create(:employer, location: 'Cupertino, CA', website: 'http://www.apple.com', commit_to_hire: 100)
      create(:employer, company_name: 'Other Employer',  location: 'Anytown, USA',
          website: 'www.other.com', commit_to_hire: 10, approved: true,
          user: create(:user, email: 'veteran1@gmail.com', password: '12345678'))
      create(:employer, company_name: 'Yet Another Employer', location: 'Anytown, USA',
          website: 'https://www.yetanother.com', approved: true, commitment_categories: ["Homeless"], commit_to_hire: 10,
          user: create(:user, email: 'veteran3@gmail.com', password: '12345678'))
    end

    it "should list the approved employers and link to their websites" do
      visit commitments_path
      expect(page).not_to have_link 'Apple Computer', href: "http://www.apple.com"
      expect(page).to have_link 'Other Employer', href: "http://www.other.com"
      expect(page).to have_link 'Yet Another Employer', href: "https://www.yetanother.com"
    end

    it "should have a downloadable CSV" do
      get commitments_path, format: 'csv'
      expect(response.content_type).to eq("text/csv")
      expect(response.status).to eq 200
    end

    it "should only show the specified columns in the CSV" do
      visit commitments_path
      click_link 'Download all commitments as a spreadsheet'
      csv = page.text
      expect(csv).to start_with "company_name,commit_date,commit_to_hire,commit_hired,website,location,note,commitment_categories"
    end

    it "should show data from allowed columns in the CSV" do
      visit commitments_path
      click_link 'Download all commitments as a spreadsheet'
      csv = page.text
      expect(csv).not_to include 'Apple Computer'
      expect(csv).to include 'Other Employer'
    end

    it "should not show data from excluded columns in the CSV" do
      visit commitments_path
      click_link 'Download all commitments as a spreadsheet'
      csv = page.text
      expect(csv).not_to include "veteran3@gmail.com"
    end

    it "should show special commitment categories on the commitments page if an employer has specified" do
      visit commitments_path
      expect(page).to have_content 'Special commitments to: Homeless'
    end

  end
end
