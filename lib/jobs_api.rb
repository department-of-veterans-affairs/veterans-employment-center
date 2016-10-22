class JobsApi < RetriableSearchRequest
  SEARCH_URL = "#{ENV['JOBS_API_BASE_URL']}/search.json"

  def search(options)
    super do
      self.class.get(SEARCH_URL, options)
    end
  end
end
