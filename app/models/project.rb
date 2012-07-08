class Project < ActiveRecord::Base
  belongs_to :user
  has_many :measured_data
  attr_accessible :description, :factor, :name, :unit
end
