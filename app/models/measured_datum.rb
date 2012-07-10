class MeasuredDatum < ActiveRecord::Base
  belongs_to :project
  attr_accessible :aggregated_value, :date, :value
  
  def self.insert_data_from_csv(project_id, datafile)
    project = Project.find(project_id.to_i)
    
    date_from = nil
    date_to = nil
    
    project.transaction do
      begin
        factor = project.factor.to_f
        lastrowvalue = 0.0
        idx = 0
        
        datafile.each do |line|
          if idx > 0
            items = line.split(';')
      
            datetime = DateTime.strptime(items[0] << 'T' << items[1], '%d.%m.%YT%H:%M:%S')
            if idx == 1
              date_from = datetime
            elsif idx == datafile.length - 1
              date_to = datetime
            end
            
            value_with_factor = items[2].to_f * factor
            project.measured_data.new(:date => datetime, :value => (idx == 1) ? 0 : value_with_factor - lastrowvalue, :aggregated_value => value_with_factor ).save!
  
            lastrowvalue = value_with_factor
          end
          
          idx += 1
        end
        
      rescue => detail
        puts detail.backtrace.join('\r\n')
      end
    end

    puts 'insert_data_from_csv DONE!'
    
    Resque.enqueue(CalculateApproximatedData, project_id, date_from, date_to, 10) #10 min
    #Resque.enqueue(CalculateApproximatedData, project_id, date_from, date_to, 1440) #1 day
  end
end
