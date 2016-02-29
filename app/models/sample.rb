class Sample < ActiveRecord::Base
has_and_belongs_to_many :measurements
belongs_to :project
has_and_belongs_to_many :attrs
has_and_belongs_to_many :attr_values
end
