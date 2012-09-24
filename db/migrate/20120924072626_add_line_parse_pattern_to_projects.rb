class AddLineParsePatternToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :line_parse_pattern, :string, :default => "d(%d.%m.%Y);d(%H:%M:%S);a"
  end
end
