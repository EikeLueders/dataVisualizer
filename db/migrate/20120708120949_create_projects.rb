class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.references :user
      t.decimal :factor, :default => 1.0
      t.string :unit
      t.text :description

      t.timestamps
    end
    add_index :projects, :user_id
  end
end
