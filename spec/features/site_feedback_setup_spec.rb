require 'rails_helper'

feature 'only admins can access site_feedback index' do
  before do
    @user = create :user, email: "am-i-an-admin@thissite.com"
  end

  scenario "non-admin can not visit site_feedback index route" do
    visit site_feedbacks_path
    expect(page).to have_content "You are not authorized"
  end


  scenario "logged in admin user visits site_feedback index, and they see the site_feedbacks" do
    sign_in_as_admin
    visit site_feedbacks_path
    expect(page).to have_content "Listing Site Feedback"
  end
end

