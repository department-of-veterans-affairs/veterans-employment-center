class AddApprovedByToEmployer < ActiveRecord::Migration
  def change
    add_column :employers, :approved_by, :string
    add_column :employers, :approved_on, :date
  end
end
