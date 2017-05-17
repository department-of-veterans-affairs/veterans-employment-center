class RetriableSearchRequest
  include HTTParty

  default_timeout 10

  MAX_ATTEMPTS = 2

  def search(_options)
    attempts = 0

    begin
      attempts += 1
      yield

    rescue Timeout::Error
      if attempts >= MAX_ATTEMPTS
        raise
      else
        retry
      end
    end
  end
end
