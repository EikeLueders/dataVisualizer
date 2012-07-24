class CreateApproximatedMeasuredData < ActiveRecord::Migration
  def change
    create_table :approximated_measured_data do |t|
      t.references :project
      t.integer :resolution
      t.decimal :value, :precision => 32, :scale => 6
      t.datetime :date
      t.decimal :aggregated_value, :precision => 32, :scale => 6

      t.timestamps
    end
    add_index :approximated_measured_data, :project_id
  end
end
