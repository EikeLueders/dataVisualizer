class CalculateApproximatedData
  @queue = :calculate_approximated_data

  def self.perform(project_id, date_from, date_to, resolution)
    # if project_id and date_from and date_to and resolution
    #   raise ArgumentError, "invalid parameters"
    # end
    
    puts "CalculateApproximatedData for project: #{project_id} with resolution #{resolution} from #{date_from} to #{date_to}"
    ApproximatedMeasuredDatum.calculate_approximated_data(project_id, date_from, date_to, resolution)
  end
end
