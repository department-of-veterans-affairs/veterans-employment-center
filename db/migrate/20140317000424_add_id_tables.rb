class AddIdTables < ActiveRecord::Migration
  def change
    add_column :affiliations, :veteran_id, :integer
    add_column :awards, :veteran_id, :integer
    add_column :experiences, :veteran_id, :integer
    add_column :references, :veteran_id, :integer
  end
end
