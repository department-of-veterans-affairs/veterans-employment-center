require 'rails_helper'

describe 'JobSearch' do
  describe "/search_jobs" do
    context "when there are search results" do
      before do
        stub_request(:get, "http://api2.us.jobs/?cname=&ind=&key=#{ENV['US_JOBS_API_KEY']}&kw=java&moc=&onet=&rd1=25&re=25&rs=1&searchType=basic&tm=&zc=washington,%20dc").
          to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/us.jobs/java_dc.xml"))
      end

      context "when there are no featured jobs for a given search" do
        before do
          stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=0&query=java%20jobs%20in%20washington,%20dc&size=25").
            to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/jobs_api/empty.json"))
          stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=0&query=java%20jobs%20in%20washington,%20dc&size=11").
            to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/jobs_api/empty.json"))
        end

        it "should only display results for the main job search results" do
          visit for_job_seekers_path
          fill_in 'kw', with: "java"
          fill_in 'zc', with: "washington, dc"
          click_button('job-search')
          expect(page).to have_no_content "Featured jobs"
          expect(page).to have_content "Java Developer - Java, Spring, Hibernate"
          expect(page).to have_content "Remote PHP Developer to join our dynamic adrtising agency!"
          expect(page).to have_no_content 'More jobs'
          expect(page).to have_content "Displaying results 1 - 25 of 373 (page 1 of 15)"

        end

        it "should only display results for federal jobs when specified (none returned here)" do
          visit for_job_seekers_path
          fill_in 'kw', with: "java"
          fill_in 'zc', with: "washington, dc"
          select 'Federal Jobs Only', :from => "fed"
          click_button('job-search')
          expect(page).to have_no_content "Featured jobs"
          expect(page).to have_no_content "Java Developer - Java, Spring, Hibernate"
          expect(page).to have_no_content "Remote PHP Developer to join our dynamic adrtising agency!"
          expect(page).to have_no_content "Displaying results 1 - 25 of 373 (page 1 of 15)"
        end
      end

      context "when federal jobs only" do
        before do
          stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=0&query=analyst%20jobs%20&size=25").
            to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/jobs_api/more_than_25_results.json"))
        end

        it "should display 25 federal results with next links" do
          visit for_job_seekers_path
          fill_in 'kw', with: "analyst"
          select 'Federal Jobs Only', :from => "fed"
          click_button('job-search')
          expect(page).to have_content "Federal jobs"
          expect(page).to have_content "Next Page"
          expect(page).to have_content "Displaying results 1 - 25"
          expect(page).to have_no_content "page 1 of"
          expect(page.all(".federal_job_posting").length).to be >= 25
        end
      end

      context "when the featured job API returns an error" do
        before do
          stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=0&query=java%20jobs%20in%20washington,%20dc&size=11").
            to_return(:status => 500)
        end

        it "should display search results with no featured results" do
          visit for_job_seekers_path
          fill_in 'kw', with: "java"
          fill_in 'zc', with: "washington, dc"
          click_button('job-search')
          expect(page).to have_no_content "Featured jobs"
          expect(page).to have_content "Java Developer - Java, Spring, Hibernate"
          expect(page).to have_content "Remote PHP Developer to join our dynamic adrtising agency!"
          expect(page).to have_content "Displaying results 1 - 25 of 373 (page 1 of 15)"
        end
      end

      context "when there are featured jobs for a given search" do
        context "when there are less than 10 featured results" do
          before do
            stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=0&query=java%20jobs%20in%20washington,%20dc&size=11").
              to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/jobs_api/less_than_10_results.json"))
          end

          it "should display all the featured results" do
            visit for_job_seekers_path
            fill_in 'kw', with: "java"
            fill_in 'zc', with: "washington, dc"
            click_button('job-search')
            expect(page).to have_content 'Featured jobs'
            expect(page).to have_content 'from employers that have committed to hiring veterans'
            expect(page).to have_content 'PL/SQL and Java Developer'
            expect(page).to have_content 'L&I Java Developer'
            expect(page).to have_content 'Java Developer - Expert Level (ITS5: SQ12) 06320'
          end

          it "should not display featured results when user selects non-federal jobs only" do
            visit for_job_seekers_path
            fill_in 'kw', with: "java"
            fill_in 'zc', with: "washington, dc"
            select 'Non-Federal Jobs Only', :from => "fed"
            click_button('job-search')
            expect(page).to have_no_content 'Featured jobs'
            expect(page).to have_no_content 'employers that have committed to hiring veterans'
            expect(page).to have_no_content 'PL/SQL and Java Developer'
            expect(page).to have_no_content 'L&I Java Developer'
            expect(page).to have_no_content 'Java Developer - Expert Level (ITS5: SQ12) 06320'
            expect(page).to have_content 'Java Developer, Senior Booz Allen Hamilton'
          end

          context 'filtering by employer' do
            before do
              stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=0&organization_name=Carolina&query=java%20jobs%20&size=11").
                to_return(:status => 200, :body => JSON.parse(File.read(Rails.root.to_s + "/spec/support/jobs_api/less_than_10_results.json"))[0..0].to_json)
              stub_request(:get, "http://api2.us.jobs/?cname=Carolina&ind=&key=#{ENV['US_JOBS_API_KEY']}&kw=java&moc=&onet=&rd1=25&re=25&rs=1&searchType=basic&tm=&zc=").
                to_return(:status => 200, :body => "")
            end

            it 'should provided filtered results' do
              visit for_job_seekers_path
              fill_in 'kw', with: "java"
              click_link 'Advanced Search'
              fill_in 'cname', with: 'Carolina'
              click_button('job-search')
              expect(page).to have_content 'Featured jobs'
              expect(page).to have_content 'from employers that have committed to hiring veterans'
              expect(page).to have_content 'PL/SQL and Java Developer'
              expect(page).to have_no_content 'L&I Java Developer'
              expect(page).to have_no_content 'Java Developer - Expert Level (ITS5: SQ12) 06320'
              expect(page).to have_no_content 'Java Developer, Senior Booz Allen Hamilton'
            end

          end
        end

        context "when there are more than 10 featured results", js: true, driver: :webkit do

          before do
            # First page of 10
            stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=0&query=java%20jobs%20in%20washington,%20dc&size=11").
              to_return(:status => 200, :body => JSON.parse(File.read(Rails.root.to_s + "/spec/support/jobs_api/more_than_25_results.json"))[0..10].to_json)
            # Second page
            stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=10&query=java%20jobs%20in%20washington,%20dc&size=11").
              to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/jobs_api/less_than_10_results.json"))
          end

          it 'should page through featured results' do
            visit for_job_seekers_path
            fill_in 'kw', with: "java"
            fill_in 'zc', with: "washington, dc"
            click_button('job-search')
            expect(page).to have_selector('.feature .job-row', count: 10)
            expect(page).to have_content 'Featured jobs'
            expect(page).to have_content 'from employers that have committed to hiring veterans'
            find('.feature a.next_page_link').trigger(:click)
            expect(page).to have_selector('.feature .job-row', count: 3)
            expect(page).to have_content 'Featured jobs'
            expect(page).to have_content 'from employers that have committed to hiring veterans'
          end

        end

        context 'when there are exactly 10 featured results', js: true, driver: :webkit do

          before do
            # First page of 10
            stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=0&query=java%20jobs%20in%20washington,%20dc&size=11").
              to_return(:status => 200, :body => JSON.parse(File.read(Rails.root.to_s + "/spec/support/jobs_api/more_than_25_results.json"))[0..9].to_json)
            stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=10&query=java%20jobs%20in%20washington,%20dc&size=11").
              to_return(:status => 200, :body => [].to_json)
          end

          before do
            visit for_job_seekers_path
            fill_in 'kw', with: "java"
            fill_in 'zc', with: "washington, dc"
            click_button('job-search')
          end

          it 'should display job clarifier' do
            expect(page).to have_content 'More jobs'
          end

          it "should not paginate" do
            expect(page).to have_selector('.feature .job-row', count: 10)
            expect(page).to have_content 'Featured jobs'
            expect(page).to have_content 'from employers that have committed to hiring veterans.'
            expect(page).to have_no_selector('.feature a.next_page_link')
          end
        end
      end

      context "when there are more than 26 non-featured results" do
        before do
          # Featured results
          stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=0&query=java%20jobs%20in%20washington,%20dc&size=11").
            to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/jobs_api/less_than_10_results.json"))

          # First page of results from us.jobs
          stub_request(:get, "http://api2.us.jobs/?cname=&ind=&key=#{ENV['US_JOBS_API_KEY']}&kw=java&moc=&onet=&rd1=25&re=25&rs=1&searchType=basic&tm=&zc=washington,%20dc").
            to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/us.jobs/more_than_25_results.xml"))

          # Second page of results from us.jobs
          stub_request(:get, "http://api2.us.jobs/?cname=&ind=&key=#{ENV['US_JOBS_API_KEY']}&kw=java&moc=&onet=&rd1=25&re=50&rs=26&searchType=basic&tm=&zc=washington,%20dc").
            to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/us.jobs/more_than_25_results.xml"))

          # Third page of results from us.jobs
          stub_request(:get, "http://api2.us.jobs/?cname=&ind=&key=#{ENV['US_JOBS_API_KEY']}&kw=java&moc=&onet=&rd1=25&re=75&rs=51&searchType=basic&tm=&zc=washington,%20dc").
            to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/us.jobs/more_than_25_results.xml"))
        end

        it "should scroll to the top of the results on pagination", js: true do
          # I think verifying that scrolling happened is about as close as you
          # can get with this.
          WebMock.disable_net_connect!(:allow_localhost => true)
          visit for_job_seekers_path
          fill_in 'kw', with: "java"
          fill_in 'zc', with: "washington, dc"
          click_button('job-search')
          expect(page).to have_content 'Displaying results 1 - 25 of 64 (page 1 of 3)'
          oldpos = page.evaluate_script('$(window).scrollTop();')
          expect(page).to have_content 'Next Page'
          first('.next_page_link').click
          expect(page).to have_content 'Displaying results 26 - 50 of 64 (page 2 of 3)'
          newpos = page.evaluate_script('$(window).scrollTop();')
          expect(newpos).not_to eq(oldpos)
        end

        it "should display them correctly and have a links to the next/prev page of results" do
          visit for_job_seekers_path
          fill_in 'kw', with: "java"
          fill_in 'zc', with: "washington, dc"
          click_button('job-search')
          expect(page).to have_content 'Displaying results 1 - 25 of 64 (page 1 of 3)'
          expect(page).to have_content 'Next Page'
          first('.next_page_link').click
          expect(page).to have_content 'Displaying results 26 - 50 of 64 (page 2 of 3)'
          expect(page).to have_content 'Prev Page'
          expect(page).to have_content 'Next Page'
          first('.next_page_link').click
          expect(page).to have_content 'Displaying results 51 - 64 of 64 (page 3 of 3)'
          expect(page).to have_content 'Prev Page'
          expect(page).to have_no_content 'Next Page'
          first('.prev_page_link').click
          expect(page).to have_content 'Displaying results 26 - 50 of 64 (page 2 of 3)'
          expect(page).to have_content 'Prev Page'
          expect(page).to have_content 'Next Page'
          first('.prev_page_link').click
          expect(page).to have_content 'Displaying results 1 - 25 of 64 (page 1 of 3)'
          expect(page).to have_no_content 'Prev Page'
          expect(page).to have_content 'Next Page'
        end
      end
    end

    context "when there are no search results" do
      before do
        stub_request(:get, "http://api2.us.jobs/?cname=&ind=&key=#{ENV['US_JOBS_API_KEY']}&kw=xxxyyy&moc=&onet=&rd1=25&re=25&rs=1&searchType=basic&tm=&zc=washington,%20dc").
          to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/us.jobs/nojobs.xml"))
        stub_request(:get, "#{ENV['JOBS_API_BASE_URL']}/search.json?from=0&query=xxxyyy%20jobs%20in%20washington,%20dc&size=11").
          to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/support/jobs_api/empty.json"))
      end

      it "should display the no results message" do
        visit for_job_seekers_path
        fill_in 'kw', with: "xxxyyy"
        fill_in 'zc', with: "washington, dc"
        click_button('job-search')
        expect(page).to have_content 'There are no jobs that match the search criteria'
        expect(page).to have_no_content 'Displaying results'
      end
    end
  end
end
