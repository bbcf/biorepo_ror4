json.array!(@fus) do |fu|
  json.extract! fu, :id
  json.url fu_url(fu, format: :json)
end
