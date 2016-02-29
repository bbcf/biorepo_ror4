json.array!(@labs) do |lab|
  json.extract! lab, :id
  json.url lab_url(lab, format: :json)
end
