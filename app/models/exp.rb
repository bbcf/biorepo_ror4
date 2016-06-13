class Exp < ActiveRecord::Base

  has_and_belongs_to_many :projects
  belongs_to :user
  belongs_to :exp_type
end
