class JobsApi
  include HTTParty

  def search(options)
    self.class.get("#{ENV['JOBS_API_BASE_URL']}/search.json", options)
  end
end
