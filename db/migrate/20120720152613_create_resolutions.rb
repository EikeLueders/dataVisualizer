class CreateResolutions < ActiveRecord::Migration
  def change
    create_table :resolutions do |t|
      t.references :project
      t.integer :value

      t.timestamps
    end
    add_index :resolutions, :project_id
  end
end
