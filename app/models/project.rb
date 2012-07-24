class Project < ActiveRecord::Base
  belongs_to :user
  
  has_many :measured_data, dependent: :destroy
  has_many :approximated_measured_data, dependent: :destroy
  has_many :resolutions, dependent: :destroy
  
  attr_accessible :description, :factor, :name, :unit, :comma_separated_resolutions
  
  validates :name, :presence => true
  validates :name, :length => { :minimum => 3, :too_short => "Set a name with minimum of 3 chars." }

  validates :unit, :presence => true

  validates :factor, :presence => true
  validates :factor, :numericality => { :only_decimal => true }
  
  validates :comma_separated_resolutions, :presence => true
  #validates :comma_separated_resolutions, :format => { :with => /^\s*(\d+(\s*,\s*\d+)*)?\s*$/, :message => "Please write comma delimited integer like '10,60,720,1440'" }
  
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
