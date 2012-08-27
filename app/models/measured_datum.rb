# Represents a measured datum of an project.
class MeasuredDatum < ActiveRecord::Base
  
  belongs_to :project
  attr_accessible :aggregated_value, :date, :value
  
  # Inserts data of an uploaded file with measured data
  def self.insert_data_from_csv(project_id, datafile)
    project = Project.find(project_id.to_i)
    
    date_from = nil
    date_to = nil
    
    project.transaction do
      begin
        factor = project.factor.to_f
        lastrowvalue = 0.0
        idx = 0
        
        # Read uploaded file
        datafile.each do |line|
          if idx > 0
            # Split line by delimiter char 
            # (format is '%date;%time;%isol_value', e.g. '15.01.2012;19:48:39;2122')
            items = line.split(';')
            
            # Extract date
            datetime = DateTime.strptime(items[0] << 'T' << items[1], '%d.%m.%YT%H:%M:%S')
            
            # Regard the factor of the project
            value_with_factor = items[2].to_f * factor
            md = project.measured_data.new(:date => datetime, :value => (idx == 1) ? 0 : value_with_factor - lastrowvalue, :aggregated_value => value_with_factor)
            md.save!
            
            # Save from and to date (AFTER save!, so that the date is not saved, if an exception occures)
            if idx == 1
              date_from = datetime
            elsif idx == datafile.length - 1
              date_to = datetime
            end
  
            lastrowvalue = value_with_factor
          end
          
          idx += 1
        end
        
      rescue => e
        e.backtrace.each { |e| puts e }
      end
    end

    puts 'insert_data_from_csv DONE!'

    # calculate resolutions, which are defined in the project
    project.resolutions.each do |r|
      MeasuredDatum.enqueue_approximation_job(project_id, date_from, date_to, r.value)
    end
  end
  
  protected
  
  def self.enqueue_approximation_job(project_id, date_from, date_to, resolution)
    Resque.enqueue(CalculateApproximatedData, project_id, date_from, date_to, resolution)
  end
  
end
