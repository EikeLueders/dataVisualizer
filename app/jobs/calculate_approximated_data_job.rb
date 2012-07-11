class CalculateApproximatedData
  @queue = :calculate_approximated_data

  def self.perform(project_id, data_from, data_to, resolution)
    if project_id and data_from and data_to and resolution
      raise ArgumentError, "invalid parameters"
    end
    
    puts "CalculateApproximatedData for project: #{project_id} with resolution #{resolution} from #{data_from} to #{data_to}"
    ApproximatedMeasuredDatum.calculate_approximated_data(project_id, data_from, data_to, resolution)
  end
end
