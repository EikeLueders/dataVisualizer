# Represents a measured datum of an project.
class MeasuredDatum < ActiveRecord::Base
  
  belongs_to :project
  attr_accessible :aggregated_value, :date, :value
  
  # Inserts data of an uploaded file with measured data
  def self.insert_data_from_csv(project_id, datafile)
    project = Project.find(project_id.to_i)
    
    date_from, date_to = nil, nil
    
    # parse file lines
    parsed_lines = self.parse_lines(datafile.readlines, project.line_parse_pattern, project.line_element_delimiter, project.ignore_first_line)
    
    project.transaction do
      begin
        factor = project.factor.to_f
        last_model = nil
        idx = 0
        
        # Read uploaded file
        parsed_lines.each do |line|
          
          # check if line hash is ok
          if self.line_valid? line
            
            datetime = line[:d]
            
            # Regard the factor of the project
            aggregated_value, isolated_value = nil, nil
            if line.key? :a
              aggregated_value = line[:a].to_f * factor
            elsif line.key? :i 
              isolated_value = line[:i].to_f * factor
            end
            
            # complete other value
            if isolated_value.nil?
               
              # a[0] = 12705
              # i[0] = 1
              # a[1] = 12708
              # i[1] = ??
              
              # calculate isolated value by last aggregated value
              last_aggregated_value = last_model.nil? ? aggregated_value : last_model.aggregated_value
              isolated_value = aggregated_value - last_aggregated_value
              
            elsif aggregated_value.nil?
              
              # i[0] = 3
              # a[0] = 12705
              # i[1] = 4
              # a[1] = ??
              
              # calculate aggregated value by last aggregated value
              last_aggregated_value = last_model.nil? ? 0.0 : last_model.aggregated_value
              aggregated_value = last_aggregated_value + isolated_value
              
            end
            
            # save new datum
            md = project.measured_data.new(:date => datetime, :value => isolated_value, :aggregated_value => aggregated_value)
            md.save!
            
            # Save from and to date (AFTER save!, so that the date is not saved, if an exception occures)
            if idx == 0
              date_from = datetime
            elsif idx == parsed_lines.count-1
              date_to = datetime
            end
  
            last_model = md
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
  
  # Checks if the given line include all necassary keys to go on.
  def self.line_valid? line
    return (line.key? :d and (line.key? :a or line.key? :i))
  end
  
  def self.enqueue_approximation_job(project_id, date_from, date_to, resolution)
    Resque.enqueue(CalculateApproximatedData, project_id, date_from, date_to, resolution)
  end
  
  # Returns an array of hashes, which contains the elements defined by parse.
  # [{:a => "1234", :i => "3", :d => <datetime>"2012-03-23T23:47:03"}]
  def self.parse_lines(lines, parse, delimiter = ';', ignore_first_line = true)
    
    parses = parse.split delimiter
    
    line_values = []
    
    # ignore first line
    lines = lines[1..-1] if ignore_first_line
    
    lines.each do |line|
      date_elements = {}
      all_elements = {}
      
      # split line and save (date) elements
      el = line.split delimiter
      i = 0
      
      el.each do |e|
        p = parses[i]
        if /d\(.+\)/ =~ p
          date_elements[e] = p[2..-2]
        else
          all_elements[p.to_sym] = e
        end
        i += 1
      end
      
      # check if date elements were found
      if not date_elements.empty?
        begin
          date_str = date_elements.keys.join '-'
          date_parse = date_elements.values.join '-'
          
          all_elements[:d] = DateTime.strptime(date_str, date_parse)
        rescue => ex
          # date cannot be parsed
        end
      end
      
      line_values << all_elements if not all_elements.empty?
    end
    
    line_values
  end

  
end
