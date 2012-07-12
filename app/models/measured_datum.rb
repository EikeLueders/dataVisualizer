class MeasuredDatum < ActiveRecord::Base
  belongs_to :project
  attr_accessible :aggregated_value, :date, :value
  #validates :date, uniqueness: true
  
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
          
            begin
              items = line.split(';')
        
              datetime = DateTime.strptime(items[0] << 'T' << items[1], '%d.%m.%YT%H:%M:%S')
              
              value_with_factor = items[2].to_f * factor
              md = project.measured_data.new(:date => datetime, :value => (idx == 1) ? 0 : value_with_factor - lastrowvalue, :aggregated_value => value_with_factor)
              md.save!
              
              # Save from/to date (AFTER save!, so that the date are not saved, if an exception occures)
              if idx == 1
                date_from = datetime
              elsif idx == datafile.length - 1
                date_to = datetime
              end
    
              lastrowvalue = value_with_factor
            rescue ActiveRecord::RecordInvalid => e
              # falls datum bereits vorhanden (wg. validates :date, uniqueness: true (s.o.))
              puts "Error: Date already exists in DB - #{e.message}"
            end
          end
          
          idx += 1
        end
        
      rescue => e
      
        puts "#{e.class}: #{e.message}\n\n"
        e.backtrace.each { |e| puts e }
        
      end
    end

    puts 'insert_data_from_csv DONE!'
    
    MeasuredDatum.enqueue_approximation_job(project_id, date_from, date_to, 10) # 10 minutes
    MeasuredDatum.enqueue_approximation_job(project_id, date_from, date_to, 180) # 3 std
    MeasuredDatum.enqueue_approximation_job(project_id, date_from, date_to, 1440) # 1 day
    
  end
  
  protected
  
  def self.enqueue_approximation_job(project_id, date_from, date_to, resolution) 
    
    begin
      Resque.enqueue(CalculateApproximatedData, project_id, date_from, date_to, resolution)
    rescue ArgumentError => e
      puts "Error: #{e.message}"
    end
    
  end
  
end
