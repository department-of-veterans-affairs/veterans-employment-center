source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.2'
gem 'pg', '0.15.1'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-validation-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'caracal-rails', '1.0.1'
gem 'caracal', '1.0.2'
gem 'va_common', '0.4.1'
gem "font-awesome-rails"
gem 'enumerize'
gem 'newrelic_rpm'
gem 'httparty', '0.13.1'
gem 'nokogiri', '~> 1.6'
gem 'will_paginate', '~> 3.0'
gem "ransack", '1.6.6'
gem "pg_search"
gem 'geocoder'
gem 'devise'
gem 'omniauth-oauth2'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin' #for some reason oauth2 doesn't work
gem 'linkedin'
gem 'omniauth-saml', '~> 1.4.0'
gem 'ruby-saml', git: "https://github.com/greggersh/ruby-saml", branch: "vaafi-1.0.0"
gem 'activerecord-session_store', git: 'https://github.com/rails/activerecord-session_store'
gem 'schema_plus_pg_indexes'
gem 'schema_plus_core', git: 'https://github.com/mikeauclair/schema_plus_core', branch: "handle_quoted_newline"
gem 'puma', '3.2.0'

# Generates fake data. Used to create data for staging environment's fictitious veterans, awards, affiliations, employers, etc.
gem 'ffaker'
gem 'city-state'
gem 'therubyracer'
gem 'libv8', '3.16.14.11'

# For UUID generation
gem 'rubysl-securerandom'

group :development, :test do
  gem 'brakeman'
  gem 'rspec-rails', '~> 3.1.0'
  gem 'capybara', '~> 2.3.0'
  gem 'factory_girl_rails', '4.2.1'
  gem 'database_cleaner', git: 'https://github.com/bmabey/database_cleaner'
  gem 'launchy'
  gem 'hirb'
  gem 'quiet_assets'
  gem 'capybara-webkit', '~> 1.7.1'
  gem 'pry'
  gem 'pry-rails'
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'bundler-audit'
end

group :test do
  gem 'webmock'
  gem 'simplecov', require: false
end

group :production do
  gem 'rails_12factor', '0.0.2'

  # Allows deployment to configure environment
  gem 'figaro', '~> 1.1', '>= 1.1.1'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
