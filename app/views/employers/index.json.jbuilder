json.array!(@employers) do |employer|
  json.extract! employer, :id
  json.url employer_url(employer, format: :json)
end
