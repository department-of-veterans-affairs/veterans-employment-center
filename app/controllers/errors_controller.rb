class ErrorsController < ApplicationController
  def error404
    redirect_to "https://www.vets.gov/not_found"
  end
end
