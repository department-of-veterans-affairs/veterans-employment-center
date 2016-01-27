class UsJobsSearch
  include HTTParty
  BASE_URI = 'http://api2.us.jobs/'
  API_KEY = ENV['US_JOBS_API_KEY']

  def search(options)
    self.class.get(BASE_URI, :query => options.merge(:key => API_KEY))
  end
end
