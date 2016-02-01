# Veterans Employment Center [![Build Status](https://api.travis-ci.org/department-of-veterans-affairs/veterans-employment-center.svg?branch=master)](https://api.travis-ci.org/department-of-veterans-affairs/veterans-employment-center)

# Installation
 * Ensure you are running Ruby 2.2.3
   * Install [Ruby Version Manager](http://rvm.io/)
   * `rvm install 2.2.3`
   * Make sure `ruby --version` says 2.2.3

 * Ensure you have [Postgres](http://www.postgresql.org/) installed and running
   * [Instructions](http://www.moncefbelyamani.com/how-to-install-postgresql-on-a-mac-with-homebrew-and-lunchy/) using Homebrew

 * Clone the project repository:

   `$ git clone git@github.com/department-of-veterans-affairs/veterans-employment-center.git`

 * Install gems and dependencies:

   `$ bundle install`
   See "Troubleshooting" below for issues

 * Create databases and load DB schemas:

   `$ rake db:create`

   `$ rake db:schema:load`

 * Load Data

   * Option A: If you have a database dump (e.g. `VEC-prod-dump-20150828`) you can restore it into a db like so (switch out `employmentportal_production` as needed):

       `pg_restore --verbose --no-owner --no-acl -d employmentportal_production --clean VEC-prod-dump-20150828`

   * Option B: Seed your database tables--Note: This step may take 30-40 minutes:

       `$ rake db:seed`

 * In the rails console, create an admin user for you to use:

   `$ rails c`
   `> User.create(email: 'your@email.com', password: 'yourpassword', admin: true)`

 * You should be good to go!

  * Start the application

      * `$ rails s`

  * Go to it in your browser at [http://127.0.0.1:3000](http://127.0.0.1:3000)

### Troubleshooting

#### Problem:
```
> bundle install
[...]
Gem::Installer::ExtensionBuildError: ERROR: Failed to build gem native extension.

    /System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/bin/ruby extconf.rb
Command 'qmake -spec macx-g++ ' not available


Gem files will remain installed in /var/folders/v4/qnj11mtx601glqpd1wymfd6h0000gn/T/bundler20150811-9857-iq0snu/capybara-webkit-1.3.1/gems/capybara-webkit-1.3.1 for inspection.
Results logged to /var/folders/v4/qnj11mtx601glqpd1wymfd6h0000gn/T/bundler20150811-9857-iq0snu/capybara-webkit-1.3.1/gems/capybara-webkit-1.3.1/./gem_make.out
An error occurred while installing capybara-webkit (1.3.1), and Bundler cannot
continue.
Make sure that `gem install capybara-webkit -v '1.3.1'` succeeds before
bundling.
```

#### Fix:

`brew install qt`

# Git Worklow

  - `$ git checkout -b YOUR_BRANCH_NAME` (creates a new feature branch and switches to it)
  - `$ git add .`
  - `$ git commit -am 'YOUR MESSAGE'` (commit as many times as you need)

  Then to submit a pull request for code review/approval:

  - `$ git push origin YOUR_BRANCH_NAME`

  Once approved, merge and push to staging:

  - `$ git checkout master` (switches to master branch)
  - `$ git pull` (makes sure master is up to date)
  - `$ git checkout YOUR_BRANCH_NAME` (switches to your feature branch)
  - `$ git rebase -i master`
  - Change the word 'pick' on all but one line to 'f'. Do not change the first line to 'f'! Save and close.
  - `$ git checkout master`
  - `$ git merge YOUR_BRANCH_NAME`
  - `$ git push origin master`
  - `$ git push staging master` (pushes to staging)
  - `$ git branch -d YOUR_BRANCH_NAME` (deletes your local branch)
  - `$ git push origin :YOUR_BRANCH_NAME` (deletes branch on GitHub)

# Employment Center 101

Common military codes to test the skills translator include 11B and 88M.

Default browser at VA is IE9 Compatibility Mode with IE7 Document Standards.

# Environment variables

The Veteran Employment Center relies on a number of environment variables for setting various values used in the application. The project is set up to use the dotenv gem, which means, for local development, you can put these environment variables in a local file, .env, and they will be used by the application in development.  For use in other environments, you'll have to make sure that the application context has access to the environment variables.

Here's a list of the environment variables used by the application:

  - DEVISE_SECRET_KEY - secret key for Devise; set with value from `rake secret`
  - GI_BILL_SAML_SERVICE_URL - Callback URL for the GI Bill SAML login; not really used
  - GOOGLE_OAUTH_CLIENT_ID - OAuth Client ID for Google Auth
  - GOOGLE_OAUTH_CLIENT_SECRET - OAuth Client Secret for Google Auth
  - JOBS_API_BASE_URL - URL to the VA Jobs API server
  - LINKEDIN_OAUTH_CLIENT_ID - OAuth Client ID for LinkedIn Auth
  - LINKEDIN_OAUTH_CLIENT_SECRET - OAuth Client Secret for LinkedIn Auth
  - NEW_RELIC_LICENSE_KEY - License key for New Relic
  - ONET_TOKEN - Access token for the O-Net API
  - SAML_CERT_FINGERPRINT - Fingerprint for the SAML cert for AccessVA/DS Logon
  - SAML_SERVICE_URL - Callback URL for SAML/DS Logon authentication
  - SAML_SSO_TARGET_URL - Target remote URL for AccessVA/DS Logon authentication
  - US_JOBS_API_KEY - Key for accessing the US.jobs API
  - SKILLS_TRANSLATOR_MODEL_ID - The skill translator model to use. This variable has to be increased every time the model gets retrained from new userdata.
  - SKILLS_TRANSLATOR_PERCENT_SKILLS_RANDOM - To ensure that we occasionally test all skills, no matter how irrelevant we thought they were, we randomly replace a few of our "relevant" skills with totally random skills.
  - SKILLS_TRANSLATOR_NUM_SKILLS_TO_RETURN - The number of skills the backend should return for a branch and MOC. A number of these skills are picked at random (see variable above).
  - SKILLS_TRANSLATOR_RELEVANCE_EXPONENT - A large exponent tends to return skills in order of relevance. A small exponent will tend to pick more at random, surfacing more low-relevance skills. Zero will return skills completely random.

# VA Jobs API

The VEC relies on the VA Jobs API for featured job results.

  https://github.com/adhocteam/jobs_api/tree/va-jobs

There's a test instance up at va-jobs-api-staging.herokuapp.com, and a production instance at va-jobs-api.herokuapp.com.

# Points of Contact

NLX API:
- Gerassimides, Pam <pgerassimides@naswa.org>
- Terrell, Charlie <cterrell@naswa.org>
