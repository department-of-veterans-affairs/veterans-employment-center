class AddCommitmentsToEmployer < ActiveRecord::Migration
  def change
    add_column :employers, :commit_date, :date
    add_column :employers, :commit_to_hire, :integer
    add_column :employers, :commit_hired, :integer
  end
end
