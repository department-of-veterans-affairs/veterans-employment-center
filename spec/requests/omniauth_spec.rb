require 'rails_helper' 

describe Users::OmniauthCallbacksController do
  describe "Logging in with third-party providers" do
    context "when logging in with LinkedIn" do
      before do
        visit new_user_session_path
      end
      
      context "when invalid credentials are provided" do
        before do
          OmniAuth.config.mock_auth[:linkedin] = :invalid_credentials
        end
        
        after do
          OmniAuth.config.add_mock(:linkedin, PROVIDERS[:linkedin])
        end
      
        it "should redirect the user to the sign in page with an error message" do
          click_link 'Sign in with LinkedIn'
          expect(page).to have_content 'Could not authenticate you from LinkedIn because "Invalid credentials".'
        end
      end
    end
    
    context "when logging in with Google" do
      before do
        visit new_user_session_path
      end
            
      context "when invalid credentials are provided" do
        before do
          OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
        end
      
        after do
          OmniAuth.config.add_mock(:google_oauth2, PROVIDERS[:google_oauth2])
        end
        
        it "should redirect the user to the sign in page with an error message" do
          click_link 'Sign in with Google'
          expect(page).to have_content 'Could not authenticate you from GoogleOauth2 because "Invalid credentials".'
        end
      end
    end
  end
end