require 'rails_helper'

describe "Veterans" do

  describe "GET /favorites" do
    it "should not load for an anonymous visitor" do
      get favorites_path
      expect(response.status).to eq 302
    end

    it "should have the employer menu" do
      employer = employer_user
      sign_in_as employer
      visit favorites_path
      expect(page).to have_content 'Sign Out'
    end
  end

  describe "GET /veterans" do
    it "should not load for an anonymous visitor" do
      get veterans_path
      expect(response.status).to eq 302
    end

    it "should have the employer menu" do
      employer = employer_user
      sign_in_as employer
      visit favorites_path
      expect(page).to have_content 'Sign Out'
    end

    context "when user is a signed in employer" do
      before do
        @user1 = create :user, email: 'suzy@veteran.org', password: 'Password'
        @user2 = create :user, email: 'soozy@veteran.org', password: 'Password'
        create :veteran, name: "Suzy Veteran", email: 'suzy@veteran.org', objective: "Build great web apps.", user: @user1, visible: true
        create :veteran, name: "Soozy Veteran", email: 'soozy@veteran.org', objective: "Build better web apps.", user: @user2, visible: true
        @unapproved_employer = employer_user
        @approved_employer = employer_user
        @approved_employer.employer.update_attributes(approved: true)
      end

      it "should load for an unapproved employer user but not show veteran names and not have download results link and not have download all veterans link" do
        sign_in_as @unapproved_employer
        visit veterans_path
        expect(page).to have_content 'Search for Veterans'
        expect(page).to have_content 'Candidate'
        expect(page).not_to have_content 'Suzy'
        expect(page).not_to have_link 'Download a spreadsheet of these results'
        expect(page).not_to have_link "Download a spreadsheet of all veterans"
      end

      it "should load for an approved employer user, show veteran names, and have download results link and not have download all veterans link" do
        sign_in_as @approved_employer
        visit veterans_path
        expect(page).to have_content 'Search for Veterans'
        expect(page).not_to have_content 'Candidate'
        expect(page).to have_content 'Suzy'
        expect(page).to have_link 'Download a spreadsheet of these results'
        expect(page).not_to have_link "Download a spreadsheet of all veterans"
      end
    end


    context "when user is an admin" do
      before do
        @user1 = create :user, email: 'suzy@veteran.org', password: 'Password'
        @user2 = create :user, email: 'soozy@veteran.org', password: 'Password'
        create :veteran, name: "Suzy Veteran", email: 'suzy@veteran.org', objective: "Build great web apps.", user: @user1, visible: true
        create :veteran, name: "Soozy Veteran", email: 'soozy@veteran.org', objective: "Build better web apps.", user: @user2, visible: true
      end

        it "should load for an admin user, show veteran names, and have download results link and have download all veterans link" do
          sign_in_as_admin
          visit veterans_path
          expect(page).to have_content 'Search for Veterans'
          expect(page).not_to have_content 'Candidate'
          expect(page).to have_content 'Suzy'
          expect(page).to have_link 'Download a spreadsheet of these results'
          expect(page).to have_link "Download a spreadsheet of all veterans"
        end
    end

    pending "should not load for a veteran user"
    pending "should not have 0 results for an employer user"
    pending "should show search fields for employer user"
  end

  describe "GET /candidate_veterans_download" do
    before do
      @user1 = create :user, email: 'suzy@veteran.org', password: 'Password'
      @user2 = create :user, email: 'soozy@veteran.org', password: 'Password'
      create :veteran, name: "Suzy Veteran", email: 'suzy@veteran.org', objective: "Build great web apps.", user: @user1, visible: true
      create :veteran, name: "Soozy Veteran", email: 'soozy@veteran.org', objective: "Build better web apps.", user: @user2, visible: true
      @approved_employer = employer_user
      @approved_employer.employer.update_attributes(approved: true)
    end

    it "spreadsheet should have proper content" do
      sign_in_as @approved_employer
      visit veterans_path
      expect(page).to have_link "Download a spreadsheet of these results"
      click_link("Download a spreadsheet of these results")
      csv = page.text
      expect(csv).to start_with "id,desiredLocation,desiredPosition,objective"
      expect(csv).to include "Suzy"
      expect(csv).to include "suzy@veteran.org"
      expect(csv).to include "Build great web apps"
      expect(csv).to include "Soozy"
      expect(csv).to include "soozy@veteran.org"
      expect(csv).to include "Build better web apps"
    end
  end

  describe "GET /download_all_veterans" do
    before do
      @user1 = create :user, email: 'suzy@veteran.org', password: 'Password'
      @user2 = create :user, email: 'soozy@veteran.org', password: 'Password'
      create :veteran, name: "Suzy Veteran", email: 'suzy@veteran.org', objective: "Build great web apps.", user: @user1, visible: true
      create :veteran, name: "Soozy Veteran", email: 'soozy@veteran.org', objective: "Build better web apps.", user: @user2, visible: true
    end

    it "spreadsheet should have proper content" do
      sign_in_as_admin
      visit veterans_path
      expect(page).to have_link "Download a spreadsheet of all veterans"
      click_link("Download a spreadsheet of all veterans")
      csv = page.text
      expect(csv).to start_with "id,desiredLocation,desiredPosition,objective"
      expect(csv).to include "Suzy"
      expect(csv).to include "suzy@veteran.org"
      expect(csv).to include "Build great web apps"
      expect(csv).to include "Soozy"
      expect(csv).to include "soozy@veteran.org"
      expect(csv).to include "Build better web apps"
    end
  end
end
