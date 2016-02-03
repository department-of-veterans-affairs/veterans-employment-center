require 'rails_helper'

describe "SiteFeedback" do

  describe "GET /site_feebacks_new" do
    it "should load for all users" do
      visit  new_site_feedback_path
      expect(page).to have_content('Employment Center Feedback')
    end
  end

  describe "GET /site_feedbacks" do

    it "should not load for an unauthorized admin user" do
      get site_feedbacks_path
      expect(response.status).to eq 302
    end

    it "should load for an admin user" do
      @user = create :user, email: "admin@thissite.com"
      sign_in_as_admin
      get site_feedbacks_path
      expect(response.status).to eq 200
    end

    it "should produce a downloadable .csv file for admin user" do
      @user = create :user, email: "admin@thissite.com"
      sign_in_as_admin
      get download_site_feedback_path, format: 'csv'
      expect(response.content_type).to eq("text/csv")
      expect(response.status).to eq 200
    end
  end




end

