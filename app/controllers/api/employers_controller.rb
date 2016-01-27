class Api::EmployersController < ApplicationController

  def index 
    @employers = Employer.where.not(job_postings_url: [nil, ""])
  end
end

