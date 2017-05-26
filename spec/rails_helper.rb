require 'simplecov'
SimpleCov.start 'rails' do
  add_filter "/vendor/"
end
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'webmock/rspec'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods
  config.include Warden::Test::Helpers
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.before(:suite) do
    Warden.test_mode!
    DatabaseCleaner.clean_with(:truncation)
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  config.before(:each, js: false) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:each) do
    Warden.test_reset!
  end
end

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

OmniAuth.config.test_mode = true

PROVIDERS = {}
PROVIDERS[:linkedin] = {
  provider: 'linkedin',
  uid: '123545',
  info: {
    name: 'Test LinkedIn User',
    email: 'test@linkedin.com'
  }
}
PROVIDERS[:google_oauth2] = {
  provider: 'google_oauth2',
  uid: '12345',
  info: {
    name: 'Test Google User',
    email: 'test@gmail.com'
  }
}
PROVIDERS[:linkedin_resume] = {
  provider: 'linkedin',
  uid: '123545',
  info: {
    name: 'Test LinkedIn User',
    email: 'test@linkedin.com'
  },
  extra: {
    access_token: {
      token: "access_token",
      secret: "secret_token"
    }
  }
}


PROVIDERS.each do |key, value|
  OmniAuth.config.add_mock(key, value)
end
