json.array!(@attrs) do |attr|
  json.extract! attr, :id
  json.url attr_url(attr, format: :json)
end
