class ApproximatedMeasuredDatum < ActiveRecord::Base
  belongs_to :project
  attr_accessible :aggregated_value, :date, :resolution, :value
  #validates :date, uniqueness: true
  
  def self.calculate_approximated_data(project_id, date_from, date_to, resolution)
    project = Project.find(project_id.to_i)
    
    project.transaction do
    
      begin
        data_to_approx = []
        
        # Workaround für Datumsabfrage ["date BETWEEN ? AND ?", date_from, date_to] 
        # (ActiveRecord verwendet dann nur Datum, nicht Zeit...)
        db_from = date_from.to_time.strftime("%Y-%m-%d %H:%M:%S")
        db_to = date_to.to_time.strftime("%Y-%m-%d %H:%M:%S")
        cond = "date BETWEEN '#{db_from}' AND '#{db_to}'"
        #puts "cond: #{cond}"
        
        differ = TimeIntervalDiffer.new(resolution)
        
        measured_data_list = project.measured_data.all(:order => 'date ASC', :conditions => [cond])
        
        i = 0
        measured_data_list.each do |datum|
        
          differ << datum.date.to_time
        
          if differ.new_interval? or i == (measured_data_list.length - 1)
            
            # Approximierte Werte fuer gegebene Datums errechnen
            approx_interval_datum = approximate_interval_data(data_to_approx)
            
            approx_datum = project.approximated_measured_data.new(:date => approx_interval_datum[:date], :resolution => resolution, :value => approx_interval_datum[:value], :aggregated_value => approx_interval_datum[:aggregated_value])
            approx_datum.save!
            
            # reset
            data_to_approx = []
            next_timespan = false
          end
          
          #puts "#{datum.date}    #{datum.value}  #{datum.aggregated_value}"
          # Datum gehoert erst zum naechsten Intervall
          data_to_approx << datum
          
          i += 1
        end
            
      rescue => e
      
        puts "Exception raised: #{e.message}\n\n"
        e.backtrace.each { |e| puts e }
        
      end
    end

    puts 'calculate_approximated_data DONE!'
  end
  
  def self.approximate_interval_data(data_to_approx)
  
    # Nicht aggregierten Wert bilden
    sum = data_to_approx.inject(0) do |sum, item| 
      sum + item.value
    end

    # Aggregierte Werte berechnen
    aggregated_sum = data_to_approx.inject(0) do |sum, item| 
      sum + item.aggregated_value
    end
    aggregated_average = aggregated_sum / data_to_approx.length

    # Datum zwischen End- und Anfangsdatum errechnen
    first_time = data_to_approx.first.date.to_time
    last_time  = data_to_approx.last.date.to_time
    middle_date = first_time + ((last_time - first_time) / 2)
    
    {date: middle_date, value: sum, aggregated_value: aggregated_average}
  end
  
end
