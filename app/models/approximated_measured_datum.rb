# Represents an approximated datum of an project.
class ApproximatedMeasuredDatum < ActiveRecord::Base
  
  belongs_to :project
  attr_accessible :aggregated_value, :date, :resolution, :value
  
  # Calculates approximated data by measured data in the given resolution.
  def self.calculate_approximated_data(project_id, date_from, date_to, resolution)
    project = Project.find(project_id.to_i)
    
    # wrap in a transaction 
    project.transaction do
      begin
        data_to_approx = []
        
        # Initialize differ with the given resolution, which helps to check the time interval of two dates
        differ = TimeIntervalDiffer.new(resolution)
        
        # Workaround für Datumsabfrage ["date BETWEEN ? AND ?", date_from, date_to]
        # (ActiveRecord verwendet dabei nur das Datum, aber nicht die Zeitkomponente...)
        db_from = date_from.to_time.strftime("%Y-%m-%d %H:%M:%S")
        db_to = date_to.to_time.strftime("%Y-%m-%d %H:%M:%S")
        cond = "date BETWEEN '#{db_from}' AND '#{db_to}'"
        
        measured_data_list = project.measured_data.all(:order => 'date ASC', :conditions => [cond])
        
        i = 0
        measured_data_list.each do |datum|
        
          # assign date of datum
          differ << datum.date.to_time
        
          # is a new time interval reached? -> calculate approximated values of the last time interval
          if differ.new_interval? or i == (measured_data_list.length - 1)
            
            approx_interval_datum = approximate_interval_data(data_to_approx)
            
            approx_datum = project.approximated_measured_data.new(:date => approx_interval_datum[:date], :resolution => resolution, :value => approx_interval_datum[:value], :aggregated_value => approx_interval_datum[:aggregated_value])
            approx_datum.save!
            
            # reset
            data_to_approx = []
            next_timespan = false
          end
          
          # Datum gehoert erst zum naechsten Intervall
          data_to_approx << datum
          
          i += 1
        end
            
      rescue => e
        e.backtrace.each { |e| puts e }
      end
    end

    puts 'calculate_approximated_data DONE!'
  end
  
  # Approximates data by given measured data
  def self.approximate_interval_data(data_to_approx)
  
    # calculates isolated values
    sum = data_to_approx.inject(0) do |sum, item| 
      sum + item.value
    end

    # calculates aggregated values
    aggregated_sum = data_to_approx.inject(0) do |sum, item| 
      sum + item.aggregated_value
    end
    aggregated_average = aggregated_sum / data_to_approx.length

    # calculate date between start date and end date
    first_time = data_to_approx.first.date.to_time
    last_time  = data_to_approx.last.date.to_time
    middle_date = first_time + ((last_time - first_time) / 2)
    
    {date: middle_date, value: sum, aggregated_value: aggregated_average}
  end
  
end
