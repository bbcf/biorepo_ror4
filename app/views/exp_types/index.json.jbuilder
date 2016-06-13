json.array!(@exp_types) do |exp_type|
  json.extract! exp_type, :id
  json.url exp_type_url(exp_type, format: :json)
end
