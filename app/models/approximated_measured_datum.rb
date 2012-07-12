class ApproximatedMeasuredDatum < ActiveRecord::Base
  belongs_to :project
  attr_accessible :aggregated_value, :date, :resolution, :value
  #validates :date, uniqueness: true
  
  def self.calculate_approximated_data(project_id, date_from, date_to, resolution)
    project = Project.find(project_id.to_i)
    
    project.transaction do
    
      begin
        data_to_approx = []
        
        firstdate = nil
        nextdate = nil
        next_timespan = false
        
        #puts "#{date_from}   #{date_to}"
        
        db_from = date_from.to_time.strftime("%Y-%m-%d %H:%M:%S")
        db_to = date_to.to_time.strftime("%Y-%m-%d %H:%M:%S")
        
        cond = "date BETWEEN '#{db_from}' AND '#{db_to}'"
        #puts "cond: #{cond}"
        
        differ = TimeIntervalDiffer.new(resolution)
        
        measured_data_list = project.measured_data.all(:order => 'date ASC', :conditions => [cond])
        
        i = 0
        measured_data_list.each do |datum|
          puts "#{datum.date}    #{datum.value}  #{datum.aggregated_value}"
        
          differ << datum.date.to_time
          
          data_to_approx << datum
        
          if differ.new_interval? or i == (measured_data_list.length - 1)
        
            sum = data_to_approx.inject(0) do |sum, item| 
              sum + item.value
            end
        
            aggregated_sum = data_to_approx.inject(0) do |sum, item| 
              sum + item.aggregated_value
            end
            aggregated_average = aggregated_sum / data_to_approx.length
        
            first_time = data_to_approx.first.date.to_time
            last_time  = data_to_approx.last.date.to_time
            
            middle_date = first_time + ((last_time - first_time) / 2)
        
            approx_datum = project.approximated_measured_data.new(:date => middle_date, :resolution => resolution, :value => sum, :aggregated_value => aggregated_average)
            
            puts
            puts "  >> #{approx_datum.date}, #{approx_datum.value}, #{approx_datum.aggregated_value}"
            puts
            puts
            
            approx_datum.save!
        
            #puts "---> sum: #{sum} for #{nextdate - firstdate} sec (#{(nextdate - firstdate)/60} min)"
        
            # reset
            data_to_approx = []
            next_timespan = false
          end
          
          i += 1
        end
            
      rescue => e
      
        puts "Exception raised: #{e.message}\n\n"
        e.backtrace.each { |e| puts e }
        
      end
    end

    puts 'calculate_approximated_data DONE!'
  end
end
