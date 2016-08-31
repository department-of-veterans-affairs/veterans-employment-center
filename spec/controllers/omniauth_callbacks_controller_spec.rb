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

      it "should create the user, create a session and redirect to the Employment Center home" do
        post :google_oauth2
        expect(User.find_by_email('test@gmail.com')).not_to be_nil
        expect(response).to redirect_to employer_home_path
      end

      context "when the user already exists" do
        before do
          User.create(email: 'test@some_test_domain.com', provider: 'google_oauth2', uid: '12345')
        end

        it "should log the user in and redirect them to the home page" do
          post :google_oauth2
          expect(response).to redirect_to employer_home_path
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

      it "should create the user, create a session and redirect to the Employment Center home" do
        post :linkedin
        expect(User.find_by_email('test@linkedin.com')).not_to be_nil
        expect(response).to redirect_to employer_home_path
      end

      context "when the user already exists" do
        before do
          User.create(email: 'test@linkedin.comlinkedin', provider: 'linkedin', uid: '12345')
        end

        it "should log the user in and redirect them to the home page" do
          post :linkedin
          expect(response).to redirect_to employer_home_path
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

      it 'should redirect to the employer_home_path' do
        expect(response).to redirect_to employer_home_path
      end

      it 'should set a flash warning that says the login failed' do
        expect(flash[:warn]).to match(/failed/)
      end
    end
  end

  describe "saml" do
    context "on a successful authorization" do
      before do
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:saml]
        expect(User.find_by_provider_and_uid('SAML', '1234567890')).to be_nil
      end

      it "should create the user, start a session and redirect the user to the new veterans home" do
        post :saml
        expect(User.find_by_provider_and_uid('SAML', '1234567890')).not_to be_nil
        expect(response).to redirect_to new_veteran_path
      end

      context "when the user already exists" do
        before do
          User.create(email: 'test@saml.org', uid: '1234567890', provider: 'SAML')
        end

        it "should log in and redirect the user" do
          post :saml
          expect(response).to redirect_to new_veteran_path
        end
      end
    end
  end
end
