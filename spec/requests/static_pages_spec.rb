require 'rails_helper'

describe "Static pages" do
  describe "Home page" do
    it "should load for anyone" do
      get root_path
      expect(response.status).to eq 200
    end

   it "should have the Approve Employers top nav if a logged-in admin" do
      user_admin = create :user, email: "admin@thissite.com"
      sign_in_as_admin
      visit root_path
      expect(page).to have_link 'Approve Employers', href: "/employer-list"
    end

    it "should not have the Approve Employers top nav if user is not an admin" do
      user_not_admin = create :user, email: "not_an_admin@thissite.com"
      sign_in_as(user_not_admin)
      visit root_path
      expect(page).not_to have_link 'Approve Employers', href: "/employer-list"
    end

    it "should have the employer top nav if a logged-in employer" do
      user = employer_user
      sign_in_as(user)
      visit root_path
      expect(page).to have_link 'Sign Out'
    end

    it "should not have the employer top nav if logged in but not an employer" do
      user = create :user, email: 'test@example.com', password: '12345678'
      sign_in_as user
      visit root_path
      expect(page).not_to have_link 'Search Veterans'
    end

    it "should not have the employer top nav if not logged-in" do
      visit root_path
      expect(page).not_to have_link 'Sign Out', href: "/veterans"
    end

    it "should not have a message to email OEC if a logged-in employer who is approved" do
      approved_employer = employer_user
      approved_employer.employer.update_attributes(approved: true)
      sign_in_as approved_employer
      visit root_path
      expect(page).not_to have_content 'unable to view Veteran contact information'
    end

  end

  describe "/skills-translator" do
    context "when logged in as an employer" do
      pending "should show the logged-in version of the skills translator page" do
        expect(page).to have_content('Favorited Veterans')
      end
    end
  end
end
