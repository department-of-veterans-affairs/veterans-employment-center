class AddHoursToExperiences < ActiveRecord::Migration
  def change
    add_column :experiences, :hours, :string
  end
end
