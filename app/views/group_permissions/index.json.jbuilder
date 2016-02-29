json.array!(@group_permissions) do |group_permission|
  json.extract! group_permission, :id
  json.url group_permission_url(group_permission, format: :json)
end
