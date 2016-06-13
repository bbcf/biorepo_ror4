namespace :biorepo_ror4 do

  desc "Update projects"
  task :update_projects, [:version] do |t, args|

    ### Use rails enviroment
    require "#{Rails.root.to_s}/config/environment"

    ### Require Net::HTTP
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'
   
   Project.all.map{|p| 
puts p.to_json
if !p.key
k =  ApplicationController.new.create_key(Project, 6)
puts k
p.update_attributes({:key => k})
end
}
    
  end
end
