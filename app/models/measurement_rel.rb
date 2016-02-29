class MeasurementRel < ActiveRecord::Base
  belongs_to :parent,
  :class_name => "Measurement"
  belongs_to :child,
  :class_name => "Measurement"
end
