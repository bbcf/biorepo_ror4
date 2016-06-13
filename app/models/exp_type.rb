class ExpType < ActiveRecord::Base
    has_many :exps
    has_and_belongs_to_many :attrs
end
