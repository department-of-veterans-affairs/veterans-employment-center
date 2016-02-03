require 'rails_helper'

describe "Errors" do

  def handle_errors
     env_config = Rails.application.env_config

     show_exceptions = env_config['action_dispatch.show_exceptions']
     local_requests = env_config['action_dispatch.show_detailed_exceptions']

     # Disables Rails built-in error reports, so our custom error application
     # can handle them and render it's own templates. This overrides the cached
     # setting in Rails.application.config.consider_all_requests_local
     env_config['action_dispatch.show_detailed_exceptions'] = false

     # Render exception templates instead of raising exceptions.
     # This is the cached setting for
     # Rails.application.config.action_dispatch.show_exceptions
     env_config['action_dispatch.show_exceptions'] = true

     yield

     env_config['action_dispatch.show_exceptions'] = show_exceptions
     env_config['action_dispatch.show_detailed_exceptions'] = local_requests
   end

   around(:each) do |example|
     handle_errors(&example)
   end

  describe "404 Redirect" do
    it "should redirect 404's to vets.gov" do
      get '/new_fake_path'
      expect(response).to redirect_to('https://www.vets.gov/not_found')
    end
  end

  describe "422 Error" do
    it "should not register as an error" do
      headers = {
        "ACCEPT" => "application/json",     # This is what Rails 4 accepts
      }
      post "/veterans", { :widget => {:name => "My Widget"} }, headers
      expect(response).to be_error
    end
  end
end
