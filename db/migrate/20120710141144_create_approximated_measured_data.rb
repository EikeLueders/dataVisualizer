class CreateApproximatedMeasuredData < ActiveRecord::Migration
  def change
    create_table :approximated_measured_data do |t|
      t.references :project
      t.integer :resolution
      t.decimal :value
      t.datetime :date
      t.decimal :aggregated_value

      t.timestamps
    end
    add_index :approximated_measured_data, :project_id
  end
end
