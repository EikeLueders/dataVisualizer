class CalculateApproximatedData
  @queue = :calculate_approximated_data

  def self.perform(project_id, data_from, data_to, resolution)
    puts "CalculateApproximatedData for project: #{project_id} with resolution #{resolution}"
    ApproximatedMeasuredDatum.calculate_approximated_data(project_id, data_from, data_to, resolution)
  end
end