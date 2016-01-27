class AddCategoryToSkills < ActiveRecord::Migration
  def change
    add_column :skills, :category, :string
  end
end
