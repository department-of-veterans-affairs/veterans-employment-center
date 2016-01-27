class AddCategoryToExperience < ActiveRecord::Migration
  def change
    add_column :experiences, :category, :string
  end
end
