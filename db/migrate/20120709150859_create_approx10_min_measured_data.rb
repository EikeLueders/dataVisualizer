class CreateApprox10MinMeasuredData < ActiveRecord::Migration
  def change
    create_table :approx10_min_measured_data do |t|
      t.references :project
      t.datetime :date
      t.decimal :value
      t.decimal :aggregated_value

      t.timestamps
    end
    add_index :approx10_min_measured_data, :project_id
  end
end
