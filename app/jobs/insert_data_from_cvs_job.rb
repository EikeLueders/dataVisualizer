class InsertDataFromCSV
  @queue = :insert_data_from_csv

  def self.perform(project_id, datafile)
    puts "InsertDataFromCSV for project: #{project_id}"
    MeasuredDatum.insert_data_from_csv(project_id, datafile)
  end
end
