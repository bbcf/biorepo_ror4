json.array!(@attr_values) do |attr_value|
  json.extract! attr_value, :id
  json.url attr_value_url(attr_value, format: :json)
end
