class Project < ActiveRecord::Base
  belongs_to :user
  
  has_many :measured_data
  has_many :approximated_measured_data
  
  attr_accessible :description, :factor, :name, :unit
  
  validates :name, :presence => true
  validates :name, :length => { :minimum => 3, :too_short => "Set a name with minimum of 3 chars." }

  validates :unit, :presence => true

  validates :factor, :presence => true
  validates :factor, :numericality => { :only_decimal => true }
end
