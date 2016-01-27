module SearchHelper
  
  def addthis_url(service, url, title, params)
    track_url = URI::encode("https://www.vets.gov/jobSearchResults?tm=&kw=#{params[:kw]}&zc=#{params[:zc]}&moc=#{params[:moc]}&zc1=#{params[:zc1]}&#{params[:rd1]}&onet=#{params[:onet]}&ind=#{params[:ind]}&cname=#{params[:cname]}&tm=#{params[:tm]}")
    result = "https://www.addthis.com/bookmark.php?v=300&amp;winname=addthis&amp;pub=ra-530961ca3f69ff4f&amp;source=tbx32-300&amp;lng=en-US&amp;s="
    result += URI::encode(service)
    result += "&amp;url="
    result += URI::encode(url)
    result += "&amp;title="
    result += URI::encode(title)
    result += "&amp;ate=AT-ra-530961ca3f69ff4f/-/-/5399c1f755699300/2&amp;frommenu=1&amp;uid=5399c1f704916aea&amp;trackurl="
    result += track_url
    result += "&amp;ct=1&amp;pre="
    result += track_url
    result += "&amp;tt=0&amp;captcha_provider=nucaptcha"
    result
  end
  
  def previous_page_path(params, page, count)
    previous_params = params.clone
    previous_params.merge!("rs" => 1 + ((page - 2) * count))
    previous_params.merge!("re" => (page - 1) * count)
    previous_params.merge!("ajax" => "true")
    search_jobs_path(previous_params.symbolize_keys)
  end

  def featured_job_badge(featured_job)
    source = featured_job['id'].split(':').first.downcase
    image_tag("employers/#{source}.png", :alt => source, :class => "logo")
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
