class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.references :user
      t.decimal :factor
      t.string :unit
      t.text :description

      t.timestamps
    end
    add_index :projects, :user_id
  end
end
