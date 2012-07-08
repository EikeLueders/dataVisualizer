class MeasuredData < ActiveRecord::Base
  belongs_to :project
  attr_accessible :date, :value
end
