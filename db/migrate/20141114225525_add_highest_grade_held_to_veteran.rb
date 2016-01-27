class AddHighestGradeHeldToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :highest_grade_held, :string
  end
end
