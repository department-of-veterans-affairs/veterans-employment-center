module SearchHelper

  def previous_page_path(params, page, count)
    previous_params = params.clone
    previous_params.merge!("rs" => 1 + ((page - 2) * count))
    previous_params.merge!("re" => (page - 1) * count)
    previous_params.merge!("ajax" => "true")
    search_jobs_path(previous_params.symbolize_keys)
  end

  def featured_job_badge(featured_job)
    source = featured_job['id'].split(':').first.downcase
    image_tag("employers/#{source}.png", alt: source, class: "logo")
  end

  def next_page_path(params, page, count)
    next_params = params.clone
    next_params.merge!(rs: 1 + (page * count))
    next_params.merge!(re: (page + 1) * count)
    next_params.merge!(ajax: "true")
    search_jobs_path(next_params.symbolize_keys)
  end

  def featured_previous_page_path(params, page)
    search_jobs_path(params.symbolize_keys.merge(featured_page: page-1))
  end

  def featured_next_page_path(params, next_page=nil)
    search_jobs_path(params.symbolize_keys.merge(featured_page: next_page))
  end
end
