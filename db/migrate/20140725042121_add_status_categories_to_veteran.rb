class AddStatusCategoriesToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :status_categories, :text, :default => []
  end
end
