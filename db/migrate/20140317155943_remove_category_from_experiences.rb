class RemoveCategoryFromExperiences < ActiveRecord::Migration
  def change
    remove_column :experiences, :category
  end
end
