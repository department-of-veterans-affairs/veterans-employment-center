require 'rails_helper'

describe Users::OmniauthCallbacksController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "google_oauth2" do
    context "on a successful authorization" do
      before do
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
        expect(User.find_by_email('test@gmail.com')).to be_nil
      end

      it "should create the user, create a session and redirect to the employer profile" do
        post :google_oauth2
        user = User.find_by_email('test@gmail.com')
        expect(user).not_to be_nil
        expect(response).to redirect_to edit_employer_path(user.employer)
      end

      context "when the user already exists" do
        before do
          omniauth_google2 = OmniAuth.config.mock_auth[:google_oauth2].dup
          omniauth_google2.uid = '12347'
          omniauth_google2.info.email = 'test@some-domain.com'
          request.env["omniauth.auth"] = omniauth_google2

          user = User.create(email: 'test@some-domain.com', provider: 'google_oauth2', uid: '12347')
          employer = user.create_employer
        end

        it "should log the user in and redirect them to the employer profile" do
          post :google_oauth2
          user = User.find_by_email('test@some-domain.com')
          expect(response).to redirect_to edit_employer_path(user.employer)
        end
      end
    end
  end

  describe "linkedin" do
    context "on a successful authorization" do
      before do
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:linkedin]
        expect(User.find_by_email('test@linkedin.com')).to be_nil
      end

      it "should create the user, create a session and redirect to the employer profile" do
        post :linkedin
        user = User.find_by_email('test@linkedin.com')
        expect(user).not_to be_nil
        expect(response).to redirect_to edit_employer_path(user.employer)
      end

      context "when the user already exists" do
        before do
          omniauth_linkedin2 = OmniAuth.config.mock_auth[:linkedin].dup
          omniauth_linkedin2.uid = '123456'
          omniauth_linkedin2.info.email = 'test@linkedin.org'
          request.env["omniauth.auth"] = omniauth_linkedin2

          user = User.create(email: 'test@linkedin.org', provider: 'linkedin', uid: '123456')
          employer = user.create_employer
        end

        it "should log the user in and redirect them to the employer_profile" do
          post :linkedin
          user = User.find_by_email('test@linkedin.org')
          expect(response).to redirect_to edit_employer_path(user.employer)
        end
      end
    end

    context "when the auth information does not include an email address" do
      before do
        omniauth_auth = OmniAuth.config.mock_auth[:linkedin].dup
        omniauth_auth.uid = '12345'
        omniauth_auth.info.email = ''

        request.env["omniauth.auth"] = omniauth_auth

        post :linkedin
      end

      it 'should redirect to the commitments page' do
        expect(response).to redirect_to commitments_path
      end

      it 'should set a flash warning that says the login failed' do
        expect(flash[:warn]).to match(/failed/)
      end
    end
  end
end
