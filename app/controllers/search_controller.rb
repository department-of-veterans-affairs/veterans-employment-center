class SearchController < ApplicationController

  def search_jobs
    @search = Search::Jobs.new(params)
    @rs = @search.rs
    @jobs = @search.jobs
    @record_count = @search.record_count
    @page_count = @search.page_count
    @us_jobs_search_params = @search.us_jobs_search_params
    @featured_page = @search.featured_page

    user_id = session[:current_user_id]
    @per_page = @search.per_page
    @page = (@rs.to_i / @per_page.to_i) + 1

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.js {}
    end
  end

end
