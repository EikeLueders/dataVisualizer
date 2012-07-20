class Project < ActiveRecord::Base
  belongs_to :user
  
  has_many :measured_data
  has_many :approximated_measured_data
  has_many :resolutions
  
  attr_accessible :description, :factor, :name, :unit, :comma_separated_resolutions
  
  validates :name, :presence => true
  validates :name, :length => { :minimum => 3, :too_short => "Set a name with minimum of 3 chars." }

  validates :unit, :presence => true

  validates :factor, :presence => true
  validates :factor, :numericality => { :only_decimal => true }
  
  # getter / setter for resolution value
  def comma_separated_resolutions
    if self.resolutions.empty?
      return
    end
    self.resolutions.map { |r| r.value }.join(", ")
  end
  
  def comma_separated_resolutions=(value)
    self.save!
    
    resolution_values = value.split(/\s?,\s?/)
    self.resolutions = resolution_values.map { |value| self.resolutions.where('value = ?', value).first or self.resolutions.create(:value => value) }
  end
end
