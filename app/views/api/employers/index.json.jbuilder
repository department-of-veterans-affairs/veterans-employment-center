json.array!(@employers) do |employer|
  json.company_name employer.company_name if employer.company_name
  json.url employer.job_postings_url
end
