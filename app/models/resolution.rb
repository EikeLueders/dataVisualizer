class Resolution < ActiveRecord::Base
  belongs_to :project
  attr_accessible :value
end
