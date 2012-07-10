class ApproximatedMeasuredDatum < ActiveRecord::Base
  belongs_to :project
  attr_accessible :aggregated_value, :date, :resolution, :value
  
  def self.calculate_approximated_data(project_id, date_from, date_to, resolution)
    project = Project.find(project_id.to_i)
    
    project.transaction do
      begin
        
        data_to_approx = []
        
        firstdate = nil
        nextdate = nil
        next_timespan = false
        sum = 0.0
        
        puts "#{date_from}   #{date_to}"
        
        project.measured_data.all(:order => 'date ASC').each do |datum|
          puts "#{datum.date}    #{datum.value}"
          
          if !next_timespan
            firstdate = datum.date
            next_timespan = true
          end
          
          nextdate = datum.date
          
          data_to_approx << datum.value
          
          #puts "#{(nextdate - firstdate)}     #{datum.value}"
          
          if nextdate - firstdate > resolution * 60
            
            sum = data_to_approx.inject(0){|sum,item| sum + item}
            #puts sum
            
            data_to_approx = []
            
            next_timespan = false
          end
          
          #puts datum
        end
        
      rescue => detail
        puts detail.backtrace.join('\r\n')
      end
    end

    puts 'calculate_approximated_data DONE!'
  end
end
