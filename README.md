# Veterans Employment Center [![Build Status](https://api.travis-ci.org/department-of-veterans-affairs/veterans-employment-center.svg?branch=master)](https://travis-ci.org/department-of-veterans-affairs/veterans-employment-center)

# Installation
 * Ensure you are running Ruby 2.3.0
   * If you are not, install rbenv, which is a tool that helps install/manage versions of Ruby (Note: make sure and follow the brew's post-install instructions):

		```
		$ brew install rbenv
		```

		And follow the initialization instructions for rbenv, provided by brew

		```
		$ rbenv init
		```
		
		Using rbenv install ruby:
		
		```
		$ rbenv install 2.3.0
		```
		
		Install the bundler gem
		
		```
		gem install bundler
		```

 * Ensure you have [Postgres](http://www.postgresql.org/) installed and running
   * [Instructions](http://www.moncefbelyamani.com/how-to-install-postgresql-on-a-mac-with-homebrew-and-lunchy/) using Homebrew

 * Clone the project repository:

   ```
   $ git clone git@github.com/department-of-veterans-affairs/veterans-employment-center.git
   ```

 * Install gems and dependencies:

   ```
   $ bundle install
   ```
   See "Troubleshooting" below for issues

 * Create databases and load DB schemas:

   ```
   $ rake db:create
	$ rake db:schema:load
	```

 * Load Data: seed your database tables--Note: This step may take 30-40 minutes:

	```
	$ rake db:seed
	```

 * Start the application

    ```
    $ rails s
    ```

  * Go to VEC in your browser at [http://127.0.0.1:3000](http://127.0.0.1:3000)

## Troubleshooting

### Problem 1:
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

```
brew install qt
```


### Problem 2:
```
psql: could not connect to server: No such file or directory
Is the server running locally and accepting
connections on Unix domain socket "/tmp/.s.PGSQL.5432"
```

#### Fix:

Try running these commands:

```
rm -fr /usr/local/var/postgres
initdb /usr/local/var/postgres -E utf8
```

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

MOC codes are sourced from the DoD Occupational Database [https://www.dmdc.osd.mil/owa/odb/](https://www.dmdc.osd.mil/owa/odb/)

Default browser at VA is IE9 Compatibility Mode with IE7 Document Standards.

# Environment variables

The Veteran Employment Center relies on a number of environment variables for setting various values used in the application. The project is set up to use the dotenv gem, which means, for local development, you can put these environment variables in a local file, .env, and they will be used by the application in development.  For use in other environments, you'll have to make sure that the application context has access to the environment variables.

Contact @ayaleloehr if you need access to any of these variables

Here's a list of the environment variables used by the application:

  - DEVISE\_SECRET\_KEY - secret key for Devise; set with value from `rake secret`
  - GOOGLE\_OAUTH\_CLIENT\_ID - OAuth Client ID for Google Auth
  - GOOGLE\_OAUTH\_CLIENT\_SECRET - OAuth Client Secret for Google Auth
  - JOBS_API\_BASE\_URL - URL to the VA Jobs API server
  - LINKEDIN\_OAUTH\_CLIENT\_ID - OAuth Client ID for LinkedIn Auth
  - LINKEDIN\_OAUTH\_CLIENT\_SECRET - OAuth Client Secret for LinkedIn Auth
  - NEW\_RELIC\_LICENSE\_KEY - License key for New Relic
  - SAML\_CERT\_FINGERPRINT - Fingerprint for the SAML cert for AccessVA/DS Logon
  - SAML\_SERVICE\_URL - Callback URL for SAML/DS Logon authentication
  - SAML\_SSO\_TARGET\_URL - Target remote URL for AccessVA/DS Logon authentication
  - US\_JOBS\_API\_KEY - Key for accessing the US.jobs API
  - SKILLS\_TRANSLATOR\_MODEL\_ID - The skill translator model to use. This variable has to be increased every time the model gets retrained from new userdata.
  - SKILLS\_TRANSLATOR\_PERCENT\_SKILLS\_RANDOM - To ensure that we occasionally test all skills, no matter how irrelevant we thought they were, we randomly replace a few of our "relevant" skills with totally random skills.
  - SKILLS\_TRANSLATOR\_NUM\_SKILLS\_TO\_RETURN - The number of skills the backend should return for a branch and MOC. A number of these skills are picked at random (see variable above).
  - SKILLS\_TRANSLATOR\_RELEVANCE\_EXPONENT - A large exponent tends to return skills in order of relevance. A small exponent will tend to pick more at random, surfacing more low-relevance skills. Zero will return skills completely random.

###Becoming an administrator locally for testing

- Export the LinkedIn environment variables (you will need to either create your own LinkedIn client id and secret or talk to someone on the VEC team to get our test variables
	
```
$ export LINKEDIN_OAUTH_CLIENT_ID=put_your_client_id_here
$ export LINKEDIN_OAUTH_CLIENT_SECRET=put_your_secret_here
```

- Start VEC locally

```
$ rails s
```
- Go to [http://localhost:3000/employers](http://localhost:3000/employers)
- Click "Sign in with LinkedIn"
- Enter your LinkedIn credentials. This will create an employer user for you in VEC. 	
- In a new terminal window, `cd` to the directory VEC is in and log into the rails console

```
$ rails c
```
- In the rails console, enter the following, replacing `my@email.address` with the email address you used above to log in with LinkedIn:

```
> User.where(:email => "my@email.address").update_all(va_admin:true)
```

- Go back to [http://localhost:3000/employers](http://localhost:3000/employers) and you should see the administrative functions along the top of the page. 


# VA Jobs API

The VEC relies on the VA Jobs API for featured job results.

```
https://github.com/department-of-veterans-affairs/jobs_api/tree/va-jobs
```

# NLX API Points of Contact

- Gerassimides, Pam <pgerassimides@naswa.org>
- Terrell, Charlie <cterrell@naswa.org>
