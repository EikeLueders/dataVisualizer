class ApproximatedMeasuredDatum < ActiveRecord::Base
  belongs_to :project
  attr_accessible :aggregated_value, :date, :resolution, :value
  validates :date, uniqueness: true
  
  def self.calculate_approximated_data(project_id, date_from, date_to, resolution)
    project = Project.find(project_id.to_i)
    
    project.transaction do
      begin
        
        case resolution
          when 10
            data_to_approx = []
            
            firstdate = nil
            nextdate = nil
            next_timespan = false
            
            puts "#{date_from}   #{date_to}"
            
            db_from = date_from.to_time.strftime("%Y-%m-%d %H:%M:%S")
            db_to = date_to.to_time.strftime("%Y-%m-%d %H:%M:%S")
            
            cond = "date BETWEEN '#{db_from}' AND '#{db_to}'"
            puts "cond: #{cond}"
            
            project.measured_data.all(:order => 'date ASC', :conditions => [cond]).each do |datum|
              puts "#{datum.date}    #{datum.value}"
            
              if !next_timespan
                firstdate = datum.date
                next_timespan = true
              end
            
              nextdate = datum.date
            
              data_to_approx << datum
            
              #puts "#{(nextdate - firstdate)}     #{datum.value}"
            
              if nextdate - firstdate > resolution * 60
            
                sum = data_to_approx.inject(0) do |sum, item| 
                  sum + item.value
                end
            
                aggregated_sum = data_to_approx.inject(0) do |sum, item| 
                  sum + item.aggregated_value
                end
                aggregated_average = aggregated_sum / data_to_approx.length
            
                middle_date = data_to_approx[data_to_approx.length / 2].date
            
                approx_datum = project.approximated_measured_data.new(:date => middle_date, :resolution => resolution, :value => sum, :aggregated_value => aggregated_average)
                puts "---> #{approx_datum}"
                approx_datum.save!
            
                puts "---> sum: #{sum} for #{nextdate - firstdate} sec (#{(nextdate - firstdate)/60} min)"
            
                # reset
                data_to_approx = []
                next_timespan = false
              end
            end
            
          when 1440
            data_to_approx = []

            current_values_date = nil
            previous_values_date = nil
            first_loop = true

            db_from = date_from.to_time.strftime("%Y-%m-%d %H:%M:%S")
            db_to = date_to.to_time.strftime("%Y-%m-%d %H:%M:%S")
            
            cond = "date BETWEEN '#{db_from}' AND '#{db_to}'"
            #puts "cond: #{cond}"

            last_datum = project.measured_data.all(:order => 'date ASC', :conditions => [cond]).last
            
            project.measured_data.all(:order => 'date ASC', :conditions => [cond]).each do |datum|
              current_values_date = datum.date.to_date

              if first_loop
                first_loop = false
                previous_values_date = current_values_date
              end

              if current_values_date != previous_values_date or datum == last_datum
                
                if datum == last_datum
                  data_to_approx << datum.value
                end
                
                sum = data_to_approx.inject(0){|sum,item| sum + item}
                puts "#{sum}     #{previous_values_date}"
                data_to_approx.clear
                
                approx_datum = project.approximated_measured_data.new(:date => previous_values_date, :resolution => resolution, :value => sum, :aggregated_value => datum.aggregated_value)
                puts "---> #{approx_datum}"
                approx_datum.save!
                
              end

              data_to_approx << datum.value
              previous_values_date = datum.date.to_date
            end
            
        end
        
        
      rescue => e
      
        puts "Exception raised: #{e.message}\n\n"
        e.backtrace.each { |e| puts e }
        
      end
    end

    puts 'calculate_approximated_data DONE!'
  end
end
