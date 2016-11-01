class JobsApi < RetriableSearchRequest
  SEARCH_URL = "#{ENV['JOBS_API_BASE_URL']}/search.json"

  default_timeout 10  # Average response time is ~200-300ms

  SEARCH_URL = "#{ENV['JOBS_API_BASE_URL']}/search.json"
  MAX_ATTEMPTS = 2

  def search(options)
    super do
      self.class.get(SEARCH_URL, options)
    end
  end
end
