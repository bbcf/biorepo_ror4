require 'rubygems'
require 'zip'

class User < ActiveRecord::Base
#attr_accessible :firstname, :name, :email, :key, :unit, :allunits
has_many :projects
has_many :measurements
has_many :downloads

has_and_belongs_to_many :groups
has_and_belongs_to_many :labs

end
