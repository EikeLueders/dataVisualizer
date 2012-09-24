class AddIgnoreFirstLineToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :ignore_first_line, :boolean, :default => true
  end
end
