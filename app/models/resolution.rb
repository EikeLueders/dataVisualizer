# Contains the resolution of an project
class Resolution < ActiveRecord::Base
  belongs_to :project
  attr_accessible :value
end
