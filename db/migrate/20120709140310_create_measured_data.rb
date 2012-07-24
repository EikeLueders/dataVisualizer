class CreateMeasuredData < ActiveRecord::Migration
  def change
    create_table :measured_data do |t|
      t.references :project
      t.datetime :date
      t.decimal :value, :precision => 32, :scale => 6
      t.decimal :aggregated_value, :precision => 32, :scale => 6

      t.timestamps
    end
    add_index :measured_data, :project_id
  end
end
