class AttrValue < ActiveRecord::Base
  belongs_to :attr
  has_and_belongs_to_many :measurements
  has_and_belongs_to_many :samples
end
