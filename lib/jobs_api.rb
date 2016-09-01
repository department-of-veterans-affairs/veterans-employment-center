class JobsApi
  include HTTParty

  default_timeout 3  # Average response time is ~200-300ms

  SEARCH_URL = "#{ENV['JOBS_API_BASE_URL']}/search.json"
  MAX_ATTEMPTS = 2

  def search(options)
    attempts = 0

    begin
      attempts += 1
      self.class.get(SEARCH_URL, options)

    rescue Timeout::Error
      if attempts >= MAX_ATTEMPTS
        raise
      else
        retry
      end
    end
  end
end
