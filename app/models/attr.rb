class Attr < ActiveRecord::Base
  belongs_to :lab
  has_many :attr_values
  has_and_belongs_to_many :samples
  has_and_belongs_to_many :measurements
end
