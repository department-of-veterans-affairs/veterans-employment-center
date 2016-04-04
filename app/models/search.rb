module Search 

  DEFAULT_MOC = '11B'

  class Jobs
    attr_accessor :rs, :re, :fed, :kw, :zc, :per_page, :featured_page
    def initialize(params = {})
      # rs is the start row. API documentation says it should be a number between 1 and 500, but by using 1 the first result is lost.
      @per_page = 25
      @params = params
      @rs = (params[:rs] || "1").strip
      @featured_page = (params[:featured_page] || 1).to_i
      # re is actually the row count, not the end row, despite documentation to the contrary
      @re = (params[:re] || @per_page.to_s).strip
      @kw, @zc, @fed = params[:kw], params[:zc], params[:fed]
    end

    def featured_jobs
      @featured_jobs ||= get_featured_jobs
    end
    
    def get_featured_jobs
      return {} if fed_only?
      featured_base = api_featured_jobs[:jobs]
      return remove_federal(featured_base) if no_fed?
      featured_base
    end

    def federal_jobs
      @federal_jobs ||= get_federal_jobs
    end
    
    def get_federal_jobs
      return {} unless fed_only?
      from = (rs.to_i-1).to_s
      jobs_api_jobs = jobs_api_listings(kw, zc, per_page, from, organization_name: @params['cname'])
      jobs_api_jobs.select{|job| job if job["id"].split(':')[0] == "usajobs"}
    end

    def featured_from
      (@featured_page - 1) * 10
    end
    
    def remove_federal(jobset)
      jobset.select{|job| job if job["id"].split(':')[0] != "usajobs"}
    end
    
    def api_featured_jobs
      @api_featured_jobs ||= get_api_featured_jobs
    end

    def get_api_featured_jobs
      listings = jobs_api_listings(kw, zc, 11, featured_from.to_s, organization_name: @params['cname'])
      {jobs: listings[0..9], has_next_page: !!listings[10]}
    end
    
    def page_count
      us_jobs[:page_count] unless fed_only?
    end

    def jobs
      fed_only? ? {} : us_jobs[:jobs]
    end

    def error
      us_jobs[:error] unless fed_only?
    end
    
    def record_count
      us_jobs[:record_count] unless fed_only?
    end

    def next_featured_page
      featured_page + 1 if api_featured_jobs[:has_next_page]
    end
    
    def us_jobs
      @us_jobs ||= get_us_jobs
    end

    def get_us_jobs
      us_jobs_search_response = UsJobsSearch.new.search(us_jobs_search_params)
      us_jobs = Nokogiri::XML(us_jobs_search_response.body) if us_jobs_search_response.code == 200

      jobs = JobsParser.xml2hash(us_jobs, ["title", "url", "company", "location", "dateacquired", "jvid"])
      error = JobsParser.x_element(us_jobs, "error")
      record_count = JobsParser.x_element(us_jobs,"recordcount").to_i
      page_count = (record_count / @per_page.to_f).ceil

      {jobs: jobs, error: error, record_count: record_count, page_count: page_count}
    end

    def us_jobs_search_params
      @us_jobs_search_params ||= get_us_jobs_search_params.merge({"rs" => rs, "re" => re })
    end
    
    private

    def get_us_jobs_search_params
      valid_params = ["searchType", "kw", "zc", "moc", "zip", "rd1", "onet", "ind", "cname", "tm"]
      @params.reject{|k,v| valid_params.include?(k) == false }
    end

    def fed_only?
      fed.to_i == 1
    end

    def no_fed?
      fed.to_i == 2
    end

    # return <number> of jobs with a given query and location. Swallow errors.
    # query: job title query
    # location: job location query
    # number: number of jobs to return
    # from: return jobs starting from an index (defaults to 0)
  
    def jobs_api_listings(query, location, number, from, additional_options={})
      from ||= "0"
      location_query = "in #{location}" if (!location.nil? && !location.empty?)
      params = {
        query:
          {
            query: "#{query} jobs #{location_query}", size: number, from: from
          }.merge(additional_options.reject{|k,v| !v.present?})
      }
      jobs_api_response = JobsApi.new.search(params)
      if jobs_api_response.code == 200
	jobs_api_response.body && jobs_api_response.body.length >= 2 ? JSON.parse(jobs_api_response.body) : []
      else
        []
      end
    end

  end
end
