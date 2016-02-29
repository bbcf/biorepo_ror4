json.array!(@measurement_rels) do |measurement_rel|
  json.extract! measurement_rel, :id
  json.url measurement_rel_url(measurement_rel, format: :json)
end
