class Project < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :labs
   has_and_belongs_to_many :exps
  has_many :samples

  searchable do
    text :name, :description
    text :sample_names do
      samples.map { |sample| sample.name }
    end
    text :sample_exp_types do
      samples.map {|sample| sample.exp_type}
    end
    text :sample_protocoles do
      samples.map {|sample| sample.protocole}
    end
    text :sample_attr_values do
      samples.map {|sample| sample.attr_values.map{|av| av.name}}
    end
  end
end
