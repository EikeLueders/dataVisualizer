class CreateMeasuredData < ActiveRecord::Migration
  def change
    create_table :measured_data do |t|
      t.references :project
      t.datetime :date
      t.decimal :value

      t.timestamps
    end
    add_index :measured_data, :project_id
  end
end
