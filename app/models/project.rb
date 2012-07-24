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
  validates :comma_separated_resolutions, :format => { :with => /^\s*(\d+(\s*,\s*\d+)*)?\s*$/, :message => "Please write comma delimited integers like '10,60,720,1440'" }
  
  after_create do
    resolution_values = self.comma_separated_resolutions.split(/\s?,\s?/)
    
    # check if the resolution already exists, else create
    self.resolutions = resolution_values.map { |value| self.resolutions.where('value = ?', value).first or self.resolutions.create(:value => value) }
  end
  
  # getter / setter for resolution value
  def comma_separated_resolutions
    if @comma_separated_resolutions
      @comma_separated_resolutions
    elsif self.resolutions.empty?
      '10, 60, 180, 720, 1440, 10080' # default values
    else
      self.resolutions.map { |r| r.value }.join(", ")
    end
  end
  
  def comma_separated_resolutions=(value)
    @comma_separated_resolutions = value
  end
end
