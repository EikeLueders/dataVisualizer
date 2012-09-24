class AddLineElementDelimiterToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :line_element_delimiter, :string, :default => ";"
  end
end
