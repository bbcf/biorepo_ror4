class Measurement < ActiveRecord::Base
belongs_to :user
belongs_to :fu
has_and_belongs_to_many :attr_values
has_and_belongs_to_many :attrs
has_and_belongs_to_many :samples

has_many :parent_measurements,
    :class_name => 'MeasurementRel',
    :foreign_key => :child_id

  has_many :parents,
    :through => :parent_measurements,
    :source => :parent

  has_many :child_measurements,
    :class_name => 'MeasurementRel',
    :foreign_key => :parent_id

  has_many :children,
    :through => :child_measurements,
    :source => :child
end
